<?php

namespace App\Http\Requests\Transaction;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'amount' => 'sometimes|numeric',
            'date' => 'sometimes|date',
            'category_id' => 'sometimes|exists:categories,id',
            'project_id' => 'nullable|exists:projects,id', // ✅ AJOUTER
            'note' => 'nullable|string|max:500',
            'source' => 'nullable|string|max:255',
            'tags' => 'nullable|array',
            'tags.*' => 'string|max:50',
            'receipt' => 'nullable|image|max:2048',
            'is_recurring' => 'boolean',
            'recurring_frequency' => 'required_if:is_recurring,true|in:daily,weekly,monthly,yearly',
        ];
    }

    public function messages(): array
    {
        return [
            'project_id.exists' => 'Le projet sélectionné n\'existe pas', // ✅ AJOUTER
        ];
    }
}