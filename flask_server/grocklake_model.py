import os
from flask import Flask, request, jsonify
from groclake.cataloglake import CatalogLake
from groclake.modellake import ModelLake
from groclake.datalake import DataLake
from groclake.vectorlake import VectorLake
import json
import google.generativeai as genai
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, storage

load_dotenv()
GROCLAKE_API_KEY=os.getenv('GROCLAKE_API_KEY')
GROCLAKE_ACCOUNT_ID=os.getenv('GROCLAKE_ACCOUNT_ID')
model_lake = ModelLake()
datalake = DataLake()
vectorlake = VectorLake()
que_history=[]
def generate_que(que_history,profile):


    
    # Expanded payload with multiple prompts
    payload = {
        "messages": [
            {
                "role": "system",
                "content": profile
            },
            {
                "role": "user",
                "content": f"Based on the user's profile and the following question history, generate 1 unique multiple-choice question related to finance that helps the user improve their financial knowledge. The question must not repeat or closely resemble any question in the history. Return the result in JSON format with keys as question, options (as a list), correct option letter, and correct answer.\n\n Question history: {question_history}" ,
            },
            
        ]
    }
    
    chat_response = ModelLake().chat_complete(payload)
    chat_answer = chat_response["answer"]
    que_history.append(chat_answer)
    k=convert_to_json(profile,chat_answer)
    generate_info(k)
    return k

def convert_to_json(profile,string):
    try:
        k=json.loads(string)
    except:
        generate_que(profile)
        

def generate_info(js):
    api=os.getenv('GEMINI_API_KEY')

    genai.configure(api_key=api)

    # Create the model
    generation_config = {
    "temperature": 1,
    "top_p": 0.95,
    "top_k": 40,
    "max_output_tokens": 8192,
    "response_mime_type": "text/plain",
    }

    model = genai.GenerativeModel(
    model_name="gemini-1.5-flash",
    generation_config=generation_config,
    )

    chat_session = model.start_chat()

    response = chat_session.send_message(f"Explain in detail about {js['question']} and justify the correct answer {js['correct_answer']}. Also provide 100 lines of info about this topic")
    file_name = "info_for_rag.txt"


    with open(file_name, "w") as file:
        file.write(response.text)

    return response.text

def upload_document():
    """Upload a document to DataLake and process it for VectorLake."""
    global datalake_id, vectorlake_id

    try:
        # Step 1: Create DataLake and VectorLake if not already created
        if not datalake_id:
            datalake_create = datalake.create()
            if "datalake_id" in datalake_create:
                datalake_id = datalake_create["datalake_id"]
                print(f"DataLake created with ID: {datalake_id}")
            else:
                print(f"Error creating DataLake: {datalake_create}")
                return jsonify({"error": "Failed to create DataLake"}), 500
        
        if not vectorlake_id:
            vector_create = vectorlake.create()
            if "vectorlake_id" in vector_create:
                vectorlake_id = vector_create["vectorlake_id"]
                print(f"VectorLake created with ID: {vectorlake_id}")
            else:
                print(f"Error creating VectorLake: {vector_create}")
                return jsonify({"error": "Failed to create VectorLake"}), 500

        # Step 2: Get document URL from request
        document_url = request.json.get("info_for_rag.txt")
        if not document_url:
            return jsonify({"error": "Document URL is required."}), 400

        # Step 3: Push the document to DataLake
        payload_push = {
            "datalake_id": datalake_id,
            "document_type": "url",
            "document_data": document_url
        }
        data_push = datalake.push(payload_push)
        document_id = data_push.get("document_id")
        if not document_id:
            return jsonify({"error": "Failed to push document."}), 500

        print(f"Document pushed successfully with ID: {document_id}")

        # Step 4: Fetch and process the document
        payload_fetch = {
            "document_id": document_id,
            "datalake_id": datalake_id,
            "fetch_format": "chunk",
            "chunk_size": "500"
        }
        data_fetch = datalake.fetch(payload_fetch)
        document_chunks = data_fetch.get("document_data", [])
        print(f"Document fetched successfully. Total chunks: {len(document_chunks)}")

        # Step 5: Push chunks to VectorLake
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

        return jsonify({"message": "Document processed successfully!"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

def chat(query):
    """Chat endpoint for processing user queries."""
    try:
       
        # Step 2: Generate vector for the user query
        vector_search_data = vectorlake.generate(query)
        search_vector = vector_search_data.get("vector")

        # Step 3: Search VectorLake
        search_payload = {
            "vector": search_vector,
            "vectorlake_id": vectorlake_id,
            "vector_type": "text",
        }
        search_response = vectorlake.search(search_payload)
        
        # Print the search response for debugging
        print("Search Response:", search_response)

        search_results = search_response.get("results", [])
        
        # Step 4: Construct enriched context
        enriched_context = " ".join([result.get("vector_document", "") for result in search_results])

        # Step 5: Query ModelLake with enriched context
        payload = {
            "messages": [
                {"role": "system", 
                 "content": "You are a highly knowledgeable assistant with expertise in financial advising. Use the provided context to answer the user's query in a concise and accurate manner.\n\n Instructions:\n - Base your response solely on the provided context.\n - If the context does not contain sufficient information, acknowledge this and do not make unsupported assumptions.\n- Provide clear and actionable insights relevant to the user's query.\n\n"
},
                {
                    "role": "user",
                    "content": f"Using the following context: {enriched_context}, "
                               f"answer the question: {query}."
                }
            ]
        }
        chat_response = model_lake.chat_complete(payload)
        answer = chat_response.get("answer", "No answer received.")
        return jsonify({"answer": answer}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500







    
if __name__ == '__main__':

    js={'question': 'Considering your long-term goal of retirement planning and your interest in retirement accounts, which of the following options would be most beneficial for you?',
     'options': ['A. Investing all your savings in a high-risk, high-return retirement account',
      'B. Ignoring retirement accounts and investing only in stocks',
      'C. Diversifying your retirement savings between a 401(k) and an Individual Retirement Account (IRA)',
      'D. Avoiding retirement accounts due to their long-term commitment'],
     'correct_option_letter': 'C',
     'correct_answer': 'Diversifying your retirement savings between a 401(k) and an Individual Retirement Account (IRA)'}
    generate_info(js)