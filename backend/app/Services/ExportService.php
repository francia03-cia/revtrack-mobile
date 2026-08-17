<?php

namespace App\Services;

use App\Models\Transaction;
use PDF;
use Excel;
use App\Exports\TransactionsExport;

class ExportService
{
    public function generatePDF($startupId, $period)
    {
        $transactions = Transaction::forStartup($startupId)
                                   ->forPeriod($period['from'], $period['to'])
                                   ->get();
        
        $data = [
            'transactions' => $transactions,
            'total' => $transactions->sum('amount'),
            'period' => $period,
            'startup' => Transaction::forStartup($startupId)->first()->startup,
        ];

        $pdf = PDF::loadView('exports.report', $data);
        
        return $pdf->output();
    }

    public function generateExcel($startupId, $filters)
    {
        return Excel::download(new TransactionsExport($startupId, $filters), 'transactions.xlsx');
    }

    public function generateCSV($startupId, $filters)
    {
        // Implémentation CSV
    }
}