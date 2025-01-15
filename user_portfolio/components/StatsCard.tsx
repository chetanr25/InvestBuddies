import { Card, CardHeader, CardTitle, CardContent } from "./ui/card";

// app/components/StatsCard.tsx
interface StatsCardProps {
    title: string;
    value: string;
    description: string;
    icon: React.ReactNode;
  }
  
  export function StatsCard({ title, value, description, icon }: StatsCardProps) {
    return (
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-sm font-medium text-muted-foreground">
            {title}
          </CardTitle>
          {icon}
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{value}</div>
          <p className="text-xs text-muted-foreground">{description}</p>
        </CardContent>
      </Card>
    );
  }