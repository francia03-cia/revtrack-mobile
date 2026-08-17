<?php

namespace App\Exports;

use App\Models\Startup;
use App\Models\Transaction;
use Maatwebsite\Excel\Concerns\FromArray;
use Maatwebsite\Excel\Concerns\WithTitle;
use Maatwebsite\Excel\Concerns\WithMultipleSheets;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\ShouldAutoSize;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use Carbon\Carbon;

class MonthlyReportExport implements WithMultipleSheets
{
    protected $startupId;
    protected $month;
    protected $year;

    public function __construct($startupId, $month = null, $year = null)
    {
        $this->startupId = $startupId;
        $this->month = $month ?? Carbon::now()->month;
        $this->year = $year ?? Carbon::now()->year;
    }

    public function sheets(): array
    {
        return [
            new SummarySheet($this->startupId, $this->month, $this->year),
            new TransactionsByPeriodSheet($this->startupId, $this->month, $this->year),
            new CategoriesSummarySheet($this->startupId, $this->month, $this->year),
        ];
    }
}

class SummarySheet implements FromArray, WithTitle, WithStyles, ShouldAutoSize
{
    protected $startupId;
    protected $month;
    protected $year;

    public function __construct($startupId, $month, $year)
    {
        $this->startupId = $startupId;
        $this->month = $month;
        $this->year = $year;
    }

    public function array(): array
    {
        $startup = Startup::find($this->startupId);
        $total = Transaction::forStartup($this->startupId)
                           ->whereMonth('date', $this->month)
                           ->whereYear('date', $this->year)
                           ->sum('amount');
        
        $count = Transaction::forStartup($this->startupId)
                           ->whereMonth('date', $this->month)
                           ->whereYear('date', $this->year)
                           ->count();

        $average = $count > 0 ? round($total / $count, 2) : 0;
        $previousMonth = Transaction::forStartup($this->startupId)
                                   ->whereMonth('date', $this->month - 1)
                                   ->whereYear('date', $this->year)
                                   ->sum('amount');
        $growth = $previousMonth > 0 ? round((($total - $previousMonth) / $previousMonth) * 100, 2) : 0;

        return [
            ['RAPPORT MENSUEL - ' . Carbon::create($this->year, $this->month)->format('F Y')],
            [''],
            ['Startup:', $startup?->name ?? 'N/A'],
            ['Période:', Carbon::create($this->year, $this->month)->format('F Y')],
            ['Date génération:', Carbon::now()->format('d/m/Y H:i')],
            [''],
            ['INDICATEURS CLÉS'],
            ['CA Total:', number_format($total, 2, ',', ' ') . ' Ar'],
            ['Nombre de transactions:', $count],
            ['Panier moyen:', number_format($average, 2, ',', ' ') . ' Ar'],
            ['Croissance vs mois précédent:', $growth . '%'],
            [''],
            ['TENDANCE'],
            ['Mois précédent:', number_format($previousMonth, 2, ',', ' ') . ' Ar'],
            ['Écart:', number_format($total - $previousMonth, 2, ',', ' ') . ' Ar'],
        ];
    }

    public function title(): string
    {
        return 'Résumé';
    }

    public function styles(Worksheet $sheet)
    {
        $sheet->getStyle('A1:B1')->applyFromArray([
            'font' => ['bold' => true, 'size' => 14],
        ]);
        $sheet->getStyle('A7:B7')->applyFromArray([
            'font' => ['bold' => true, 'size' => 12, 'color' => ['rgb' => 'FFFFFF']],
            'fill' => [
                'fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID,
                'startColor' => ['rgb' => '4F46E5'],
            ],
        ]);
    }
}

class TransactionsByPeriodSheet implements FromArray, WithTitle, WithStyles, ShouldAutoSize
{
    protected $startupId;
    protected $month;
    protected $year;

    public function __construct($startupId, $month, $year)
    {
        $this->startupId = $startupId;
        $this->month = $month;
        $this->year = $year;
    }

    public function array(): array
    {
        $transactions = Transaction::forStartup($this->startupId)
                         ->whereMonth('date', $this->month)
                         ->whereYear('date', $this->year)
                         ->with(['category', 'user'])
                         ->orderBy('date', 'desc')
                         ->get();

        $data = [['Date', 'Montant (Ar)', 'Catégorie', 'Source', 'Note', 'Créé par']];

        foreach ($transactions as $transaction) {
            $data[] = [
                $transaction->date->format('d/m/Y'),
                number_format($transaction->amount, 2, ',', ' '),
                $transaction->category?->name ?? 'Non catégorisé',
                $transaction->source ?? '-',
                $transaction->note ?? '-',
                $transaction->user?->name ?? '-',
            ];
        }

        return $data;
    }

    public function title(): string
    {
        return 'Transactions';
    }

    public function styles(Worksheet $sheet)
    {
        $sheet->getStyle('A1:F1')->applyFromArray([
            'font' => ['bold' => true, 'color' => ['rgb' => 'FFFFFF']],
            'fill' => [
                'fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID,
                'startColor' => ['rgb' => '3B82F6'],
            ],
        ]);
    }
}

class CategoriesSummarySheet implements FromArray, WithTitle, WithStyles, ShouldAutoSize
{
    protected $startupId;
    protected $month;
    protected $year;

    public function __construct($startupId, $month, $year)
    {
        $this->startupId = $startupId;
        $this->month = $month;
        $this->year = $year;
    }

    public function array(): array
    {
        $transactions = Transaction::forStartup($this->startupId)
                                  ->whereMonth('date', $this->month)
                                  ->whereYear('date', $this->year)
                                  ->with('category')
                                  ->get();

        $total = $transactions->sum('amount');
        $data = [['Catégorie', 'Montant Total (Ar)', 'Nombre', 'Pourcentage']];

        $categories = $transactions->groupBy('category_id')
                           ->map(function ($items) use ($total) {
                               $amount = $items->sum('amount');
                               return [
                                   'category' => $items->first()->category?->name ?? 'Non catégorisé',
                                   'amount' => number_format($amount, 2, ',', ' '),
                                   'count' => $items->count(),
                                   'percentage' => $total > 0 ? round(($amount / $total) * 100, 2) . '%' : '0%',
                               ];
                           })
                           ->values();

        foreach ($categories as $category) {
            $data[] = [
                $category['category'],
                $category['amount'],
                $category['count'],
                $category['percentage'],
            ];
        }

        return $data;
    }

    public function title(): string
    {
        return 'Par Catégorie';
    }

    public function styles(Worksheet $sheet)
    {
        $sheet->getStyle('A1:D1')->applyFromArray([
            'font' => ['bold' => true, 'color' => ['rgb' => 'FFFFFF']],
            'fill' => [
                'fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID,
                'startColor' => ['rgb' => '8B5CF6'],
            ],
        ]);
    }
}