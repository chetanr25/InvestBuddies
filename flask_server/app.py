import os
from flask import Flask, request, jsonify
from groclake.modellake import Modellake
from groclake.datalake import Datalake
from groclake.vectorlake import Vectorlake
import json
import google.generativeai as genai
from dotenv import load_dotenv
import cloudinary
import cloudinary.uploader
from cloudinary.utils import cloudinary_url

load_dotenv()

GROCLAKE_API_KEY = os.getenv('GROCLAKE_API_KEY')
GROCLAKE_ACCOUNT_ID = os.getenv('GROCLAKE_ACCOUNT_ID')
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')

if not all([GROCLAKE_API_KEY, GROCLAKE_ACCOUNT_ID, GEMINI_API_KEY]):
    raise ValueError("Missing required environment variables")

model_lake = Modellake()
datalake = Datalake()
vectorlake = Vectorlake()
que_history = []

app = Flask(__name__, template_folder='templates')

@app.route('/generate_que', methods=['POST']) 
def generate_que():
    try:
        p = request.json.get("profile")
        profile = str(p)
        print("profile",profile)
        if not profile:
            return jsonify({"error": "Profile is required"}), 400

        payload = {
            "messages": [
                {"role": "system", "content": profile},
                {
                    "role": "user",
                    "content": f"Based on the user's profile and the following question history, generate 1 unique multiple-choice question related to finance that helps the user improve their financial knowledge. The question must not repeat or closely resemble any question in the history. Return the result in JSON format with keys as question, options (as a list), correct option letter, and correct answer.\n\n Question history: {que_history}"
                }
            ]
        }
        # payload = {'messages': [{'role': 'system', 'content': {'ageGroup': '18-25', 'employmentStatus': 'Student', 'incomeRange': 'Less than ₹25,000', 'riskLevel': 'Low Risk - Savings accounts, bonds', 'industries': [], 'shortTermGoals': [], 'investmentInterests': [], 'challenges': []}}, {'role': 'user', 'content': "Based on the user's profile and the following question history, generate 1 unique multiple-choice question related to finance that helps the user improve their financial knowledge. The question must not repeat or closely resemble any question in the history. Return the result in JSON format with keys as question, options (as a list), correct option letter, and correct answer.\n\n Question history: []"}]}
        
        chat_response = Modellake().chat_complete(payload)
        print("chat_response",chat_response)
        chat_answer = chat_response.get("answer")
        if not chat_answer:
            return jsonify({"error": "Failed to generate question"}), 500

        question_data = convert_to_json(chat_answer)
        if not question_data:
            return jsonify({"error": "Failed to parse question data"}), 500

        que_history.append(chat_answer)
        info = generate_info(question_data)
        
        return jsonify({
            "question_data": question_data,
            # "additional_info": info
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

def convert_to_json(string):
    try:
        return json.loads(string)
    except json.JSONDecodeError as e:
        print(f"JSON parsing error: {e}")
        return None

def generate_info(js):
    try:
        genai.configure(api_key=GEMINI_API_KEY)
        
        generation_config = {
            "temperature": 1,
            "top_p": 0.95,
            "top_k": 40,
            "max_output_tokens": 8192,
        }

        model = genai.GenerativeModel(
            model_name="gemini-1.5-flash",
            generation_config=generation_config,
        )

        prompt = f"Explain in detail about {js['question']} and justify the correct answer {js['correct_answer']}. Also provide 100 lines of info about this topic"
        
        chat = model.start_chat()
        response = chat.send_message(prompt)
        print("response",response)
        if not response.text:
            raise ValueError("Empty response from Gemini")

        with open("info_for_rag.txt", "w") as file:
            file.write(response.text)
            
        return response.text

    except Exception as e:
        print(f"Error in generate_info: {e}")
        raise

datalake_id = None
vectorlake_id = None
@app.route('/upload', methods=['POST'])
def upload_document():
    """Upload a document to DataLake and process it for VectorLake."""
    global datalake_id, vectorlake_id

    try:
        if not datalake_id:
            datalake_create = datalake.create()
            if "datalake_id" in datalake_create:
                datalake_id = datalake_create["datalake_id"]
                print(f"DataLake created with ID: {datalake_id}")
            else:
                print(f"Error creating DataLake: {datalake_create}")
                return {"error": "Failed to create DataLake"}
        
        if not vectorlake_id:
            vector_create = vectorlake.create()
            if "vectorlake_id" in vector_create:
                vectorlake_id = vector_create["vectorlake_id"]
                print(f"VectorLake created with ID: {vectorlake_id}")
            else:
                print(f"Error creating VectorLake: {vector_create}")
                return {"error": "Failed to create VectorLake"}

        document_url = "content/info_for_rag.txt"
        if not document_url:
            return {"error": "Document URL is required."}
        
        url=get_url()
        payload_push = {
        "datalake_id": datalake_id,
        "document_type": "url",
        "document_data": url
        
    }

        data_push = datalake.push(payload_push)
        document_id = data_push.get("document_id")
        print("Payload to push:", payload_push)
        data_push = datalake.push(payload_push)
        print("Response from push:", data_push)

        print(document_id)
        if not document_id:
            return {"error": "Failed to push document."}

        print(f"Document pushed successfully with ID: {document_id}")

        payload_fetch = {
            "document_id": document_id,
            "datalake_id": datalake_id,
            "fetch_format": "chunk",
            "chunk_size": "500"
        }
        data_fetch = datalake.fetch(payload_fetch)
        document_chunks = data_fetch.get("document_data", [])
        print(f"Document fetched successfully. Total chunks: {len(document_chunks)}")

        for chunk in document_chunks:
            vector_doc = vectorlake.generate(chunk)
            vector_chunk = vector_doc.get("vector")
            vectorlake_push_request = {
                "vector": vector_chunk,
                "vectorlake_id": vectorlake_id,
                "document_text": chunk,
                "vector_type": "text",
                "metadata": {}
            }
            vectorlake.push(vectorlake_push_request)

        return {"message": "Document processed successfully!"}

    except Exception as e:
        return {"error": str(e)}

@app.route('/chat', methods=['POST'])
def chat():
    query= request.json.get("query")
    try:
       
        vector_search_data = vectorlake.generate(query)
        search_vector = vector_search_data.get("vector")

        search_payload = {
            "vector": search_vector,
            "vectorlake_id": vectorlake_id,
            "vector_type": "text",
        }
        search_response = vectorlake.search(search_payload)
        
        print("Search Response:", search_response)

        search_results = search_response.get("results", [])
        
        enriched_context = " ".join([result.get("vector_document", "") for result in search_results])

        payload = {
            "messages": [
                {"role": "system", 
                 "content": "You are a highly knowledgeable assistant with expertise in financial advising. Use the provided context to answer the user's query in a concise and accurate manner.\n\n "
},
                {
                    "role": "user",
                    "content": f"Using the following context: {enriched_context}, "
                               f"answer the question: {query}."
                }
            ]
        }
        print("enriched_context",enriched_context)  
        chat_response = model_lake.chat_complete(payload)
        answer = chat_response.get("answer", "No answer received.")
        return {"answer": answer}

    except Exception as e:
        return {"error": str(e)}




def get_url():
    print("Uploading file to cloudinary")
    cloudinary.config( 
        cloud_name = "dsdjgzbc0",  
        api_key = os.getenv('CLOUDINARY_API_KEY'),
        api_secret = os.getenv('CLOUDINARY_SECRERT_KEY'), 
        secure=True
    )
    
    upload_result = cloudinary.uploader.upload("info_for_rag.txt",resource_type = "raw")
    file_url=upload_result.get("url")

    print(file_url)
    return file_url

@app.route('/fin_bot', methods=['POST'])

def fin_bot():
    prompt= request.json.get("prompt")
    payload={
        "messages": [
            {
                "role": "system",
                "content": "You are an expert financial advisor providing accurate and personalized financial guidance. Your capabilities include: 1. Budget Planning: Help users track income, expenses, and savings effectively. 2. Investment Advice: Recommend suitable investment opportunities based on financial goals and risk tolerance. 3. Retirement Planning: Assist in calculating savings needed for retirement and suggest strategies. 4. Tax Optimization: Provide tips to reduce tax liability and maximize tax-efficient investments. 5. Debt Management: Create strategies to manage and pay off debts. 6. Goal-Oriented Planning: Help users achieve specific financial milestones, such as buying a house or saving for education. 7. Market Insights: Offer real-time updates and analysis of market trends. 8. Financial Education: Provide information to educate users about any finance-related topic. Please provide concise, actionable, and reliable advice to help users make informed financial decisions."

            },
            {
                "role": "user",
                "content": prompt
            },
            
        ]
    }
    print("payload",payload)
    chat_response = ModelLake().chat_complete(payload)
    print("chat_response",chat_response)
    
    chat_answer = chat_response["answer"]
    return chat_answer


if __name__ == '__main__':
    app.run()

#     js={'question': 'Considering your long-term goal of retirement planning and your interest in retirement accounts, which of the following options would be most beneficial for you?',
#      'options': ['A. Investing all your savings in a high-risk, high-return retirement account',
#       'B. Ignoring retirement accounts and investing only in stocks',
#       'C. Diversifying your retirement savings between a 401(k) and an Individual Retirement Account (IRA)',
#       'D. Avoiding retirement accounts due to their long-term commitment'],
#      'correct_option_letter': 'C',
#      'correct_answer': 'Diversifying your retirement savings between a 401(k) and an Individual Retirement Account (IRA)'}
#     # generate_info(js)
#     upload_document()
#     ans=chat("What is a 401(k) retirement account?")
#     print(ans)
