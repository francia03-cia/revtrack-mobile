<?php

namespace App\Http\Requests\Transaction;

use Illuminate\Foundation\Http\FormRequest;

class StoreTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'amount' => 'required|numeric',
            'date' => 'required|date',
            'category_id' => 'required|exists:categories,id',
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
            'amount.required' => 'Le montant est obligatoire',
            'amount.numeric' => 'Le montant doit être un nombre',
            'date.required' => 'La date est obligatoire',
            'date.date' => 'La date n\'est pas valide',
            'category_id.required' => 'La catégorie est obligatoire',
            'category_id.exists' => 'La catégorie sélectionnée n\'existe pas',
            'project_id.exists' => 'Le projet sélectionné n\'existe pas', // ✅ AJOUTER
            'receipt.image' => 'Le fichier doit être une image',
            'receipt.max' => 'L\'image ne doit pas dépasser 2MB',
        ];
    }
}