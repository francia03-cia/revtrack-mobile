<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StartupResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'logo' => $this->logo_url,
            'currency' => $this->currency,
            'email' => $this->email,
            'phone' => $this->phone,
            'address' => $this->address,
            'owner_id' => $this->user_id,
            'owner_name' => $this->owner?->name,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'stats' => [
                'total_revenue' => $this->getTotalRevenue(),
                'monthly_revenue' => $this->getMonthlyRevenue(),
                'daily_revenue' => $this->getDailyRevenue(),
                'transaction_count' => $this->transaction_count,
                'category_count' => $this->category_count,
                'user_count' => $this->user_count,
            ],
            'users' => UserResource::collection($this->whenLoaded('users')),
            'categories' => CategoryResource::collection($this->whenLoaded('categories')),
        ];
    }
}