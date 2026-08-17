<?php

namespace App\Exports;

use App\Models\Transaction;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\ShouldAutoSize;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class RevenueByCategoryExport implements 
    FromCollection, 
    WithHeadings, 
    WithMapping, 
    WithStyles,
    ShouldAutoSize
{
    protected $startupId;
    protected $period;

    public function __construct($startupId, $period = 'month')
    {
        $this->startupId = $startupId;
        $this->period = $period;
    }

    public function collection()
    {
        $query = Transaction::forStartup($this->startupId)->with('category');

        if ($this->period === 'month') {
            $query->thisMonth();
        } elseif ($this->period === 'year') {
            $query->thisYear();
        }

        $transactions = $query->get();
        $total = $transactions->sum('amount');

        return $transactions->groupBy('category_id')
                           ->map(function ($items) use ($total) {
                               $amount = $items->sum('amount');
                               return [
                                   'category' => $items->first()->category?->name ?? 'Non catégorisé',
                                   'amount' => $amount,
                                   'count' => $items->count(),
                                   'percentage' => $total > 0 ? round(($amount / $total) * 100, 2) : 0,
                               ];
                           })
                           ->values();
    }

    public function headings(): array
    {
        return [
            'Catégorie',
            'Montant Total (Ar)',
            'Nombre de Transactions',
            'Pourcentage (%)',
        ];
    }

    public function map($row): array
    {
        return [
            $row['category'],
            number_format($row['amount'], 2, ',', ' '),
            $row['count'],
            $row['percentage'] . '%',
        ];
    }

    public function styles(Worksheet $sheet)
    {
        $sheet->getStyle('A1:D1')->applyFromArray([
            'font' => [
                'bold' => true,
                'color' => ['rgb' => 'FFFFFF'],
            ],
            'fill' => [
                'fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID,
                'startColor' => ['rgb' => '10B981'],
            ],
        ]);
    }
}