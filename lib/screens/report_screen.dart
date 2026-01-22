import 'package:flutter/material.dart';
import '../services/report_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _reportService = ReportService();

  String _type = 'daily';
  bool _loading = false;
  String? _fileUrl;
  double _revenue = 0;
  List<Map<String, dynamic>> _history = [];

  Future<void> _generateReport() async {
    setState(() {
      _loading = true;
      _fileUrl = null;
    });

    try {
      final data = await _reportService.generateReport(_type);
      setState(() {
        _fileUrl = data['file'];
        _revenue = data['totalRevenue'];
        _history.insert(0, {
          'type': _type,
          'file': data['file'],
          'total': _revenue,
          'timestamp': DateTime.now().toString(),
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _downloadFile() async {
    if (_fileUrl != null) {
      await _reportService.downloadReport(_fileUrl!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report downloaded successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            onPressed: _generateReport,
            icon: const Icon(Icons.refresh),
            tooltip: 'Generate report',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildGenerateSection()),
                  const SizedBox(width: 20),
                  Expanded(flex: 3, child: _buildHistorySection()),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildGenerateSection(),
                    const SizedBox(height: 20),
                    _buildHistorySection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildGenerateSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate Report',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(
                labelText: 'Report Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily Report')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly Report')),
              ],
              onChanged: (val) => setState(() => _type = val ?? 'daily'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.analytics_outlined),
                label: const Text('Generate Report'),
                onPressed: _loading ? null : _generateReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_fileUrl != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Revenue: Rp ${_revenue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _downloadFile,
                    icon: const Icon(Icons.download),
                    label: const Text('Download Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _history.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No reports generated yet.'),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _history.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 20, color: Colors.grey),
                    itemBuilder: (context, i) {
                      final item = _history[i];
                      return ListTile(
                        leading: Icon(
                          item['type'] == 'daily'
                              ? Icons.calendar_today
                              : Icons.date_range,
                          color: Colors.blueAccent,
                        ),
                        title: Text(
                          '${item['type'].toString().toUpperCase()} REPORT',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Revenue: Rp ${item['total'].toStringAsFixed(0)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () =>
                              _reportService.downloadReport(item['file']),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}