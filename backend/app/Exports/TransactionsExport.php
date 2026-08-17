<?php

namespace App\Exports;

use App\Models\Transaction;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\ShouldAutoSize;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class TransactionsExport implements 
    FromCollection, 
    WithHeadings, 
    WithMapping, 
    WithStyles,
    ShouldAutoSize
{
    protected $startupId;
    protected $filters;
    protected $total;

    public function __construct($startupId, $filters = [])
    {
        $this->startupId = $startupId;
        $this->filters = $filters;
    }

    public function collection()
    {
        $query = Transaction::forStartup($this->startupId)
                           ->with(['category', 'user', 'startup']);

        if (isset($this->filters['date_from'])) {
            $query->whereDate('date', '>=', $this->filters['date_from']);
        }
        if (isset($this->filters['date_to'])) {
            $query->whereDate('date', '<=', $this->filters['date_to']);
        }
        if (isset($this->filters['category_id'])) {
            $query->where('category_id', $this->filters['category_id']);
        }

        $transactions = $query->orderBy('date', 'desc')->get();
        $this->total = $transactions->sum('amount');

        return $transactions;
    }

    public function headings(): array
    {
        return [
            '#',
            'Date',
            'Montant (Ar)',
            'Catégorie',
            'Source',
            'Note',
            'Tags',
            'Créé par',
            'Créé le',
        ];
    }

    public function map($transaction): array
    {
        static $rowNumber = 0;
        $rowNumber++;

        return [
            $rowNumber,
            $transaction->date->format('d/m/Y'),
            number_format($transaction->amount, 2, ',', ' '),
            $transaction->category?->name ?? 'Non catégorisé',
            $transaction->source ?? '-',
            $transaction->note ?? '-',
            implode(', ', $transaction->tags_array),
            $transaction->user?->name ?? '-',
            $transaction->created_at->format('d/m/Y H:i'),
        ];
    }

    public function styles(Worksheet $sheet)
    {
        $sheet->getStyle('A1:I1')->applyFromArray([
            'font' => [
                'bold' => true,
                'color' => ['rgb' => 'FFFFFF'],
            ],
            'fill' => [
                'fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID,
                'startColor' => ['rgb' => '4F46E5'],
            ],
        ]);

        $lastRow = $sheet->getHighestRow() + 2;
        $sheet->setCellValue("B{$lastRow}", 'TOTAL:');
        $sheet->setCellValue("C{$lastRow}", number_format($this->total, 2, ',', ' '));
        $sheet->getStyle("B{$lastRow}:C{$lastRow}")->applyFromArray([
            'font' => ['bold' => true, 'size' => 12],
        ]);
    }
}