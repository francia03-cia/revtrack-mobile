<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'amount' => $this->amount,
            'formatted_amount' => $this->formatted_amount,
            'date' => $this->date->format('Y-m-d'),
            'note' => $this->note,
            'receipt' => $this->receipt_url,
            'source' => $this->source,
            'tags' => $this->tags_array,
            'is_recurring' => $this->is_recurring,
            'recurring_frequency' => $this->recurring_frequency,
            'startup_id' => $this->startup_id,
            'startup_name' => $this->startup?->name,
            'category_id' => $this->category_id,
            'category_name' => $this->category?->name,
            'category_color' => $this->category?->color,
            'user_id' => $this->user_id,
            'user_name' => $this->user?->name,
            'is_high_value' => $this->isHighValue(),
            'is_low_value' => $this->isLowValue(),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}