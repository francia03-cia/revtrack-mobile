<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Rapport financier</title>
    <style>
        body {
            font-family: 'DejaVu Sans', 'Helvetica', 'Arial', sans-serif;
            font-size: 12px;
            color: #333;
            margin: 20px;
        }
        .header {
            text-align: center;
            border-bottom: 3px solid #4F46E5;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        .header h1 {
            font-size: 24px;
            color: #4F46E5;
            margin: 0;
        }
        .header p {
            color: #666;
            margin: 5px 0 0 0;
        }
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-bottom: 20px;
        }
        .summary-card {
            background: #f8f9fa;
            padding: 12px;
            border-radius: 8px;
            text-align: center;
            border-left: 4px solid #4F46E5;
        }
        .summary-card .label {
            font-size: 10px;
            color: #666;
            text-transform: uppercase;
            font-weight: bold;
        }
        .summary-card .value {
            font-size: 18px;
            font-weight: bold;
            margin-top: 4px;
        }
        .summary-card .value.positive { color: #10B981; }
        .summary-card .value.negative { color: #EF4444; }
        .summary-card .value.neutral { color: #4F46E5; }
        .section-title {
            font-size: 16px;
            font-weight: bold;
            color: #4F46E5;
            margin: 20px 0 10px 0;
            border-bottom: 2px solid #E5E7EB;
            padding-bottom: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            font-size: 11px;
        }
        table th {
            background: #4F46E5;
            color: white;
            padding: 8px 6px;
            text-align: left;
        }
        table td {
            padding: 6px;
            border-bottom: 1px solid #E5E7EB;
        }
        table tr:nth-child(even) {
            background: #F9FAFB;
        }
        table .amount-positive {
            color: #10B981;
            font-weight: bold;
        }
        table .amount-negative {
            color: #EF4444;
            font-weight: bold;
        }
        .chart-container {
            margin: 15px 0;
            text-align: center;
        }
        .chart-container canvas {
            max-width: 100%;
        }
        .footer {
            margin-top: 30px;
            padding-top: 10px;
            border-top: 1px solid #E5E7EB;
            font-size: 10px;
            color: #999;
            text-align: center;
        }
        .category-list {
            list-style: none;
            padding: 0;
        }
        .category-list li {
            padding: 4px 0;
            border-bottom: 1px solid #f0f0f0;
            display: flex;
            justify-content: space-between;
        }
        .category-color {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-right: 8px;
            vertical-align: middle;
        }
        .top-sources {
            margin-top: 10px;
        }
        .top-sources .source-item {
            display: flex;
            justify-content: space-between;
            padding: 4px 0;
            border-bottom: 1px solid #f0f0f0;
        }
        @page {
            margin: 15mm;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>📊 RAPPORT FINANCIER</h1>
        <p><strong>{{ strtoupper($startup->name) }}</strong></p>
        <p>Période du {{ $startDate }} au {{ $endDate }}</p>
        <p>Généré le {{ $generatedAt }}</p>
    </div>

    <!-- Résumé -->
    <div class="summary-grid">
        <div class="summary-card">
            <div class="label">Total Revenus</div>
            <div class="value positive">{{ number_format($totalRevenue, 0, ',', ' ') }} Ar</div>
        </div>
        <div class="summary-card">
            <div class="label">Total Dépenses</div>
            <div class="value negative">{{ number_format(abs($totalExpenses), 0, ',', ' ') }} Ar</div>
        </div>
        <div class="summary-card">
            <div class="label">Revenu Net</div>
            <div class="value {{ $netRevenue >= 0 ? 'positive' : 'negative' }}">
                {{ number_format($netRevenue, 0, ',', ' ') }} Ar
            </div>
        </div>
        <div class="summary-card">
            <div class="label">Transactions</div>
            <div class="value neutral">{{ $transactionCount }}</div>
        </div>
    </div>

    <!-- Top Sources -->
    @if(count($topSources) > 0)
    <div class="section-title">🏆 Top 5 des sources de revenus</div>
    <div class="top-sources">
        @foreach($topSources as $source => $amount)
        <div class="source-item">
            <span>{{ $source }}</span>
            <span class="amount-positive">{{ number_format($amount, 0, ',', ' ') }} Ar</span>
        </div>
        @endforeach
    </div>
    @endif

    <!-- Par Catégorie -->
    @if(count($categoryData) > 0)
    <div class="section-title">📂 Répartition par catégorie</div>
    <ul class="category-list">
        @foreach($categoryData as $cat)
        <li>
            <span>
                <span class="category-color" style="background: {{ $cat['color'] }};"></span>
                {{ $cat['name'] }}
            </span>
            <span>
                {{ number_format($cat['total'], 0, ',', ' ') }} Ar
                <span style="color:#999;font-size:10px;">({{ $cat['count'] }} transactions)</span>
            </span>
        </li>
        @endforeach
    </ul>
    @endif

    <!-- Liste des transactions -->
    <div class="section-title">📋 Liste des transactions</div>
    <table>
        <thead>
            <tr>
                <th>#</th>
                <th>Date</th>
                <th>Source</th>
                <th>Catégorie</th>
                <th style="text-align:right;">Montant (Ar)</th>
            </tr>
        </thead>
        <tbody>
            @foreach($transactions as $index => $transaction)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td>{{ $transaction->date->format('d/m/Y') }}</td>
                <td>{{ $transaction->source }}</td>
                <td>{{ $transaction->category?->name ?? 'Sans catégorie' }}</td>
                <td style="text-align:right;">
                    <span class="{{ $transaction->amount >= 0 ? 'amount-positive' : 'amount-negative' }}">
                        {{ number_format($transaction->amount, 0, ',', ' ') }}
                    </span>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <!-- Statistiques par mois -->
    @if(count($monthlyData) > 0)
    <div class="section-title">📈 Évolution mensuelle</div>
    <table>
        <thead>
            <tr>
                <th>Mois</th>
                <th style="text-align:right;">Total (Ar)</th>
            </tr>
        </thead>
        <tbody>
            @foreach($monthlyData as $month => $total)
            <tr>
                <td>{{ Carbon\Carbon::parse($month . '-01')->format('F Y') }}</td>
                <td style="text-align:right;">
                    <span class="{{ $total >= 0 ? 'amount-positive' : 'amount-negative' }}">
                        {{ number_format($total, 0, ',', ' ') }}
                    </span>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>
    @endif

    <!-- Évolution quotidienne -->
    @if(count($dailyData) > 0)
    <div class="section-title">📊 Évolution quotidienne</div>
    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th style="text-align:right;">Total (Ar)</th>
            </tr>
        </thead>
        <tbody>
            @foreach($dailyData as $date => $total)
            <tr>
                <td>{{ Carbon\Carbon::parse($date)->format('d/m/Y') }}</td>
                <td style="text-align:right;">
                    <span class="{{ $total >= 0 ? 'amount-positive' : 'amount-negative' }}">
                        {{ number_format($total, 0, ',', ' ') }}
                    </span>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>
    @endif

    <div class="footer">
        <p>Ce rapport a été généré automatiquement par RevTrack Mobile.</p>
        <p>Confidentiel - À usage interne uniquement</p>
        <p>{{ $startup->name }} - {{ $startup->email ?? '' }}</p>
    </div>
</body>
</html>