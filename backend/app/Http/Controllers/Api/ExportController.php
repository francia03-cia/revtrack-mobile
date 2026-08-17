<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Startup;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Carbon\Carbon;
use Barryvdh\DomPDF\Facade\Pdf;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Chart\Chart;
use PhpOffice\PhpSpreadsheet\Chart\DataSeries;
use PhpOffice\PhpSpreadsheet\Chart\DataSeriesValues;
use PhpOffice\PhpSpreadsheet\Chart\Legend;
use PhpOffice\PhpSpreadsheet\Chart\PlotArea;
use PhpOffice\PhpSpreadsheet\Chart\Title;

class ExportController extends Controller
{
    /**
     * Exporter en PDF
     */
    public function exportPDF(Request $request)
    {
        try {
            $startupId = $request->get('startup_id');
            $startDate = $request->get('start_date');
            $endDate = $request->get('end_date');

            if (!$startupId) {
                return response()->json([
                    'success' => false,
                    'message' => 'startup_id est requis',
                ], 422);
            }

            // Récupérer la startup
            $startup = Startup::findOrFail($startupId);

            // Définir les dates par défaut
            if (!$startDate) {
                $startDate = Carbon::now()->startOfMonth()->format('Y-m-d');
            }
            if (!$endDate) {
                $endDate = Carbon::now()->format('Y-m-d');
            }

            $start = Carbon::parse($startDate);
            $end = Carbon::parse($endDate);

            // Récupérer les transactions
            $transactions = Transaction::with(['category', 'user'])
                ->where('startup_id', $startupId)
                ->whereBetween('date', [$start, $end])
                ->orderBy('date', 'desc')
                ->get();

            // Calculer les statistiques
            $totalRevenue = $transactions->where('amount', '>', 0)->sum('amount');
            $totalExpenses = $transactions->where('amount', '<', 0)->sum('amount');
            $netRevenue = $totalRevenue + $totalExpenses;
            $transactionCount = $transactions->count();

            // Données par catégorie
            $categoryData = $transactions->groupBy('category_id')
                ->map(function ($items) {
                    $category = $items->first()->category;
                    return [
                        'name' => $category?->name ?? 'Sans catégorie',
                        'color' => $category?->color ?? '#6B7280',
                        'total' => $items->sum('amount'),
                        'count' => $items->count(),
                    ];
                })
                ->values()
                ->toArray();

            // Données par jour pour le graphique
            $dailyData = $transactions->groupBy(function ($item) {
                return $item->date->format('Y-m-d');
            })->map(function ($items) {
                return $items->sum('amount');
            })->toArray();

            // Données par mois
            $monthlyData = $transactions->groupBy(function ($item) {
                return $item->date->format('Y-m');
            })->map(function ($items) {
                return $items->sum('amount');
            })->toArray();

            // Top 5 sources
            $topSources = $transactions->groupBy('source')
                ->map(function ($items) {
                    return $items->sum('amount');
                })
                ->sortDesc()
                ->take(5)
                ->toArray();

            // Données pour le graphique en camembert
            $pieChartData = [];
            foreach ($categoryData as $cat) {
                $pieChartData[] = [
                    'label' => $cat['name'],
                    'value' => $cat['total'],
                    'color' => $cat['color'],
                ];
            }

            // Générer le PDF
            $pdf = Pdf::loadView('exports.report_pdf', [
                'startup' => $startup,
                'startDate' => $start->format('d/m/Y'),
                'endDate' => $end->format('d/m/Y'),
                'transactions' => $transactions,
                'totalRevenue' => $totalRevenue,
                'totalExpenses' => $totalExpenses,
                'netRevenue' => $netRevenue,
                'transactionCount' => $transactionCount,
                'categoryData' => $categoryData,
                'dailyData' => $dailyData,
                'monthlyData' => $monthlyData,
                'topSources' => $topSources,
                'pieChartData' => $pieChartData,
                'generatedAt' => Carbon::now()->format('d/m/Y H:i:s'),
            ]);

            // Options du PDF
            $pdf->setPaper('A4', 'portrait');

            // Télécharger le PDF
            $filename = 'rapport_' . $startup->name . '_' . $start->format('Y-m-d') . '_' . $end->format('Y-m-d') . '.pdf';

            return $pdf->download($filename);

        } catch (\Exception $e) {
            Log::error('❌ Export PDF Error: ' . $e->getMessage());
            Log::error($e->getTraceAsString());
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'export PDF: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Exporter en Excel
     */
    public function exportExcel(Request $request)
    {
        try {
            $startupId = $request->get('startup_id');
            $startDate = $request->get('start_date');
            $endDate = $request->get('end_date');

            if (!$startupId) {
                return response()->json([
                    'success' => false,
                    'message' => 'startup_id est requis',
                ], 422);
            }

            // Récupérer la startup
            $startup = Startup::findOrFail($startupId);

            // Définir les dates par défaut
            if (!$startDate) {
                $startDate = Carbon::now()->startOfMonth()->format('Y-m-d');
            }
            if (!$endDate) {
                $endDate = Carbon::now()->format('Y-m-d');
            }

            $start = Carbon::parse($startDate);
            $end = Carbon::parse($endDate);

            // Récupérer les transactions
            $transactions = Transaction::with(['category', 'user'])
                ->where('startup_id', $startupId)
                ->whereBetween('date', [$start, $end])
                ->orderBy('date', 'desc')
                ->get();

            // Créer le spreadsheet
            $spreadsheet = new Spreadsheet();
            
            // ============================================
            // FEUILLE 1: RÉSUMÉ
            // ============================================
            $sheet1 = $spreadsheet->getActiveSheet();
            $sheet1->setTitle('Résumé');

            // En-tête
            $sheet1->mergeCells('A1:F1');
            $sheet1->setCellValue('A1', 'RAPPORT FINANCIER - ' . strtoupper($startup->name));
            $sheet1->getStyle('A1')->getFont()->setBold(true)->setSize(16);
            $sheet1->getStyle('A1')->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

            $sheet1->mergeCells('A2:F2');
            $sheet1->setCellValue('A2', 'Période du ' . $start->format('d/m/Y') . ' au ' . $end->format('d/m/Y'));
            $sheet1->getStyle('A2')->getFont()->setSize(12);
            $sheet1->getStyle('A2')->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

            // Résumé des données
            $totalRevenue = $transactions->where('amount', '>', 0)->sum('amount');
            $totalExpenses = $transactions->where('amount', '<', 0)->sum('amount');
            $netRevenue = $totalRevenue + $totalExpenses;
            $transactionCount = $transactions->count();

            $summaryData = [
                ['Indicateur', 'Valeur'],
                ['Total des revenus', number_format($totalRevenue, 0, ',', ' ') . ' Ar'],
                ['Total des dépenses', number_format(abs($totalExpenses), 0, ',', ' ') . ' Ar'],
                ['Revenu net', number_format($netRevenue, 0, ',', ' ') . ' Ar'],
                ['Nombre de transactions', $transactionCount],
                ['Date de génération', Carbon::now()->format('d/m/Y H:i:s')],
            ];

            $row = 4;
            foreach ($summaryData as $data) {
                $col = 'A';
                foreach ($data as $value) {
                    $sheet1->setCellValue($col . $row, $value);
                    if ($row == 4 || $row == 11) {
                        $sheet1->getStyle($col . $row)->getFont()->setBold(true);
                    }
                    $col++;
                }
                $row++;
            }

            // Style pour le tableau de résumé
            $sheet1->getStyle('A4:B11')->getBorders()->getAllBorders()->setBorderStyle(Border::BORDER_THIN);
            $sheet1->getStyle('A4:B4')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('4F46E5');
            $sheet1->getStyle('A4:B4')->getFont()->setColor(new \PhpOffice\PhpSpreadsheet\Style\Color(\PhpOffice\PhpSpreadsheet\Style\Color::COLOR_WHITE));

            // Ajuster les colonnes
            foreach (range('A', 'F') as $col) {
                $sheet1->getColumnDimension($col)->setAutoSize(true);
            }

            // ============================================
            // FEUILLE 2: TRANSACTIONS
            // ============================================
            $sheet2 = $spreadsheet->createSheet();
            $sheet2->setTitle('Transactions');

            // En-têtes
            $headers = ['#', 'Date', 'Source', 'Catégorie', 'Montant (Ar)', 'Note', 'Utilisateur'];
            $col = 'A';
            foreach ($headers as $header) {
                $sheet2->setCellValue($col . '1', $header);
                $sheet2->getStyle($col . '1')->getFont()->setBold(true);
                $sheet2->getStyle($col . '1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('4F46E5');
                $sheet2->getStyle($col . '1')->getFont()->setColor(new \PhpOffice\PhpSpreadsheet\Style\Color(\PhpOffice\PhpSpreadsheet\Style\Color::COLOR_WHITE));
                $col++;
            }

            // Données
            $row = 2;
            $index = 1;
            foreach ($transactions as $transaction) {
                $sheet2->setCellValue('A' . $row, $index);
                $sheet2->setCellValue('B' . $row, $transaction->date->format('d/m/Y'));
                $sheet2->setCellValue('C' . $row, $transaction->source);
                $sheet2->setCellValue('D' . $row, $transaction->category?->name ?? 'Sans catégorie');
                $sheet2->setCellValue('E' . $row, $transaction->amount);
                $sheet2->setCellValue('F' . $row, $transaction->note);
                $sheet2->setCellValue('G' . $row, $transaction->user?->name ?? '');

                // Colorer les montants négatifs en rouge
                if ($transaction->amount < 0) {
                    $sheet2->getStyle('E' . $row)->getFont()->setColor(new \PhpOffice\PhpSpreadsheet\Style\Color(\PhpOffice\PhpSpreadsheet\Style\Color::COLOR_RED));
                }

                $row++;
                $index++;
            }

            // Style du tableau
            $lastRow = $row - 1;
            $sheet2->getStyle('A1:G' . $lastRow)->getBorders()->getAllBorders()->setBorderStyle(Border::BORDER_THIN);

            // Ajuster les colonnes
            foreach (range('A', 'G') as $col) {
                $sheet2->getColumnDimension($col)->setAutoSize(true);
            }

            // ============================================
            // FEUILLE 3: STATISTIQUES PAR CATÉGORIE
            // ============================================
            $sheet3 = $spreadsheet->createSheet();
            $sheet3->setTitle('Par catégorie');

            // En-têtes
            $headers = ['Catégorie', 'Total (Ar)', 'Nombre', 'Pourcentage'];
            $col = 'A';
            foreach ($headers as $header) {
                $sheet3->setCellValue($col . '1', $header);
                $sheet3->getStyle($col . '1')->getFont()->setBold(true);
                $sheet3->getStyle($col . '1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('4F46E5');
                $sheet3->getStyle($col . '1')->getFont()->setColor(new \PhpOffice\PhpSpreadsheet\Style\Color(\PhpOffice\PhpSpreadsheet\Style\Color::COLOR_WHITE));
                $col++;
            }

            // Données
            $categoryData = $transactions->groupBy('category_id')
                ->map(function ($items) {
                    $category = $items->first()->category;
                    return [
                        'name' => $category?->name ?? 'Sans catégorie',
                        'total' => $items->sum('amount'),
                        'count' => $items->count(),
                    ];
                })
                ->values()
                ->toArray();

            $totalAmount = array_sum(array_column($categoryData, 'total'));
            $row = 2;
            foreach ($categoryData as $data) {
                $percentage = $totalAmount > 0 ? ($data['total'] / $totalAmount) * 100 : 0;
                $sheet3->setCellValue('A' . $row, $data['name']);
                $sheet3->setCellValue('B' . $row, $data['total']);
                $sheet3->setCellValue('C' . $row, $data['count']);
                $sheet3->setCellValue('D' . $row, number_format($percentage, 2) . '%');
                $row++;
            }

            // Total
            $sheet3->setCellValue('A' . $row, 'TOTAL');
            $sheet3->getStyle('A' . $row)->getFont()->setBold(true);
            $sheet3->setCellValue('B' . $row, $totalAmount);
            $sheet3->getStyle('B' . $row)->getFont()->setBold(true);

            // Style du tableau
            $sheet3->getStyle('A1:D' . $row)->getBorders()->getAllBorders()->setBorderStyle(Border::BORDER_THIN);

            // Ajuster les colonnes
            foreach (range('A', 'D') as $col) {
                $sheet3->getColumnDimension($col)->setAutoSize(true);
            }

            // ============================================
            // FEUILLE 4: TOP SOURCES
            // ============================================
            $sheet4 = $spreadsheet->createSheet();
            $sheet4->setTitle('Top sources');

            // En-têtes
            $sheet4->setCellValue('A1', 'Source');
            $sheet4->setCellValue('B1', 'Total (Ar)');
            $sheet4->getStyle('A1:B1')->getFont()->setBold(true);
            $sheet4->getStyle('A1:B1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('4F46E5');
            $sheet4->getStyle('A1:B1')->getFont()->setColor(new \PhpOffice\PhpSpreadsheet\Style\Color(\PhpOffice\PhpSpreadsheet\Style\Color::COLOR_WHITE));

            // Données
            $topSources = $transactions->groupBy('source')
                ->map(function ($items) {
                    return $items->sum('amount');
                })
                ->sortDesc()
                ->take(10)
                ->toArray();

            $row = 2;
            foreach ($topSources as $source => $amount) {
                $sheet4->setCellValue('A' . $row, $source);
                $sheet4->setCellValue('B' . $row, $amount);
                $row++;
            }

            // Style du tableau
            $sheet4->getStyle('A1:B' . ($row - 1))->getBorders()->getAllBorders()->setBorderStyle(Border::BORDER_THIN);

            // Ajuster les colonnes
            $sheet4->getColumnDimension('A')->setAutoSize(true);
            $sheet4->getColumnDimension('B')->setAutoSize(true);

            // Créer le fichier Excel
            $writer = new Xlsx($spreadsheet);
            $filename = 'transactions_' . $startup->name . '_' . $start->format('Y-m-d') . '_' . $end->format('Y-m-d') . '.xlsx';

            // Sauvegarder temporairement
            $tempPath = storage_path('app/temp/' . $filename);
            if (!is_dir(storage_path('app/temp'))) {
                mkdir(storage_path('app/temp'), 0755, true);
            }
            $writer->save($tempPath);

            // Télécharger
            return response()->download($tempPath, $filename)->deleteFileAfterSend(true);

        } catch (\Exception $e) {
            Log::error('❌ Export Excel Error: ' . $e->getMessage());
            Log::error($e->getTraceAsString());
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'export Excel: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Exporter les transactions en CSV
     */
    public function exportCSV(Request $request)
    {
        try {
            $startupId = $request->get('startup_id');
            $startDate = $request->get('start_date');
            $endDate = $request->get('end_date');

            if (!$startupId) {
                return response()->json([
                    'success' => false,
                    'message' => 'startup_id est requis',
                ], 422);
            }

            $startup = Startup::findOrFail($startupId);

            if (!$startDate) {
                $startDate = Carbon::now()->startOfMonth()->format('Y-m-d');
            }
            if (!$endDate) {
                $endDate = Carbon::now()->format('Y-m-d');
            }

            $start = Carbon::parse($startDate);
            $end = Carbon::parse($endDate);

            $transactions = Transaction::with(['category', 'user'])
                ->where('startup_id', $startupId)
                ->whereBetween('date', [$start, $end])
                ->orderBy('date', 'desc')
                ->get();

            $filename = 'transactions_' . $startup->name . '_' . $start->format('Y-m-d') . '_' . $end->format('Y-m-d') . '.csv';
            $headers = [
                'Content-Type' => 'text/csv',
                'Content-Disposition' => "attachment; filename=\"$filename\"",
            ];

            $callback = function () use ($transactions) {
                $file = fopen('php://output', 'w');
                
                // En-têtes
                fputcsv($file, ['#', 'Date', 'Source', 'Catégorie', 'Montant (Ar)', 'Note', 'Utilisateur']);

                foreach ($transactions as $index => $transaction) {
                    fputcsv($file, [
                        $index + 1,
                        $transaction->date->format('d/m/Y'),
                        $transaction->source,
                        $transaction->category?->name ?? 'Sans catégorie',
                        $transaction->amount,
                        $transaction->note,
                        $transaction->user?->name ?? '',
                    ]);
                }

                fclose($file);
            };

            return response()->stream($callback, 200, $headers);

        } catch (\Exception $e) {
            Log::error('❌ Export CSV Error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'export CSV: ' . $e->getMessage(),
            ], 500);
        }
    }
}