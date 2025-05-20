import 'package:flutter/material.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:language_app/provider/report_provider.dart';
import 'package:language_app/models/report_model.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:language_app/utils/toast_helper.dart';
import 'package:language_app/provider/user_provider.dart';

class ReportManagementScreen extends StatefulWidget {
  const ReportManagementScreen({Key? key}) : super(key: key);

  @override
  State<ReportManagementScreen> createState() => _ReportManagementScreenState();
}

class _ReportManagementScreenState extends State<ReportManagementScreen> {
  bool _isLoading = true;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMorePages = true;
  String? _selectedFilter;
  final ScrollController _scrollController = ScrollController();

  final Map<String, String> reportReasonLabels = {
    'spam': 'Spam',
    'abuse': 'Lạm dụng',
    'harassment': 'Quấy rối',
    'inappropriate': 'Không phù hợp',
    'copyright': 'Vi phạm bản quyền',
    'other': 'Khác',
  };

  @override
  void initState() {
    super.initState();
    _loadReports();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_hasMorePages && !_isLoading) {
          _loadMoreReports();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);

      // Kiểm tra quyền admin từ thông tin người dùng
      if (userProvider.user == null) {
        await userProvider.getUserInfo(context);
      }

      if (userProvider.user == null || userProvider.user!.role != 'admin') {
        ToastHelper.showError(context, 'Bạn không có quyền truy cập trang này');
        Navigator.pop(context);
        return;
      }

      final success = await reportProvider.fetchAllReports(
        page: _currentPage,
        limit: _pageSize,
      );

      if (!success) {
        ToastHelper.showError(context, 'Không thể tải báo cáo');
      }
    } catch (e) {
      ToastHelper.showError(context, 'Đã xảy ra lỗi: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreReports() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentPage++;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);

      // Kiểm tra quyền admin từ thông tin người dùng
      if (userProvider.user == null || userProvider.user!.role != 'admin') {
        ToastHelper.showError(context, 'Bạn không có quyền truy cập trang này');
        Navigator.pop(context);
        return;
      }

      final success = await reportProvider.fetchAllReports(
        page: _currentPage,
        limit: _pageSize,
      );

      // Nếu không có báo cáo nào được trả về, đánh dấu không còn trang nào nữa
      if (reportProvider.reports.isEmpty ||
          reportProvider.reports.length < _pageSize) {
        setState(() {
          _hasMorePages = false;
        });
      }

      if (!success) {
        ToastHelper.showError(context, 'Không thể tải thêm báo cáo');
      }
    } catch (e) {
      ToastHelper.showError(context, 'Đã xảy ra lỗi: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter(String? filter) {
    setState(() {
      _selectedFilter = filter;
      _currentPage = 1;
      _hasMorePages = true;
    });
    _loadReports();
  }

  List<ReportModel> _getFilteredReports(List<ReportModel> reports) {
    if (_selectedFilter == null) return reports;

    if (_selectedFilter == 'resolved') {
      return reports.where((report) => report.isResolved == true).toList();
    } else if (_selectedFilter == 'pending') {
      return reports.where((report) => report.isResolved == false).toList();
    } else {
      // Filter by reason
      return reports
          .where((report) => report.reason == _selectedFilter)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.indigo.shade50],
            stops: const [0.0, 0.7],
          ),
        ),
        child: Column(
          children: [
            TopBar(
              title: "Quản lý báo cáo",
            ),
            _buildFilterSection(pix),
            Expanded(
              child: _buildReportList(pix),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(double pix) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * pix, vertical: 8 * pix),
      color: Colors.white.withOpacity(0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lọc báo cáo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16 * pix,
            ),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả', null),
                _buildFilterChip('Đã xử lý', 'resolved'),
                _buildFilterChip('Chưa xử lý', 'pending'),
                ...reportReasonLabels.entries.map((entry) {
                  return _buildFilterChip(entry.value, entry.key);
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _selectedFilter == value;

    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          _applyFilter(selected ? value : null);
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildReportList(double pix) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, child) {
        if (_isLoading && reportProvider.reports.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        final filteredReports = _getFilteredReports(reportProvider.reports);

        if (filteredReports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 60 * pix,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  _selectedFilter != null
                      ? 'Không có báo cáo nào phù hợp với bộ lọc'
                      : 'Không có báo cáo nào',
                  style: TextStyle(
                    fontSize: 16 * pix,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 10 * pix),
                if (_selectedFilter != null)
                  ElevatedButton(
                    onPressed: () => _applyFilter(null),
                    child: Text('Xóa bộ lọc'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadReports,
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(16 * pix),
            itemCount: filteredReports.length + (_hasMorePages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == filteredReports.length) {
                return _buildLoadingIndicator();
              }
              return _buildReportCard(filteredReports[index], pix);
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildReportCard(ReportModel report, double pix) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16 * pix),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showReportDetails(report),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16 * pix),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: report.isResolved
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    child: Icon(
                      report.isResolved ? Icons.check : Icons.flag,
                      color: report.isResolved ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Báo cáo bài viết #${report.postId}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16 * pix,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: report.isResolved
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                report.isResolved ? 'Đã xử lý' : 'Chưa xử lý',
                                style: TextStyle(
                                  color: report.isResolved
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 12 * pix,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Lý do: ${reportReasonLabels[report.reason] ?? report.reason}',
                          style: TextStyle(
                            fontSize: 14 * pix,
                            color: isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (report.description != null &&
                  report.description!.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  'Mô tả: ${report.description}',
                  style: TextStyle(
                    fontSize: 14 * pix,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Báo cáo bởi: ${report.userName ?? 'Người dùng #${report.userId}'}',
                    style: TextStyle(
                      fontSize: 13 * pix,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    timeago.format(report.createdAt, locale: 'vi'),
                    style: TextStyle(
                      fontSize: 13 * pix,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!report.isResolved)
                    OutlinedButton.icon(
                      icon: Icon(Icons.check, size: 18),
                      label: Text('Đánh dấu đã xử lý'),
                      onPressed: () => _markAsResolved(report),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      icon: Icon(Icons.undo, size: 18),
                      label: Text('Đánh dấu chưa xử lý'),
                      onPressed: () => _markAsUnresolved(report),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: Icon(Icons.delete, size: 18),
                    label: Text('Xóa'),
                    onPressed: () => _confirmDelete(report),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetails(ReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle indicator
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12, bottom: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: report.isResolved
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    child: Icon(
                      report.isResolved ? Icons.check : Icons.flag,
                      color: report.isResolved ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chi tiết báo cáo #${report.id}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          report.isResolved ? 'Đã xử lý' : 'Chưa xử lý',
                          style: TextStyle(
                            color:
                                report.isResolved ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(),

            // Detail content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem(
                      'Bài viết',
                      'ID: ${report.postId}',
                      Icons.article,
                      Colors.blue,
                      onTap: () {
                        // Navigate to post detail, implement later if needed
                        ToastHelper.showInfo(
                            context, 'Chức năng đang phát triển');
                      },
                    ),

                    _buildDetailItem(
                      'Người báo cáo',
                      report.userName ?? 'ID: ${report.userId}',
                      Icons.person,
                      Colors.purple,
                    ),

                    _buildDetailItem(
                      'Lý do báo cáo',
                      reportReasonLabels[report.reason] ?? report.reason,
                      Icons.flag,
                      Colors.red,
                    ),

                    if (report.description != null &&
                        report.description!.isNotEmpty)
                      _buildDetailItem(
                        'Mô tả chi tiết',
                        report.description!,
                        Icons.description,
                        Colors.amber,
                        multiline: true,
                      ),

                    _buildDetailItem(
                      'Thời gian báo cáo',
                      '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year} ${report.createdAt.hour}:${report.createdAt.minute}',
                      Icons.access_time,
                      Colors.green,
                    ),

                    SizedBox(height: 24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!report.isResolved)
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.check),
                              label: Text('Đánh dấu đã xử lý'),
                              onPressed: () {
                                Navigator.pop(context);
                                _markAsResolved(report);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.undo),
                              label: Text('Đánh dấu chưa xử lý'),
                              onPressed: () {
                                Navigator.pop(context);
                                _markAsUnresolved(report);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.delete),
                            label: Text('Xóa báo cáo'),
                            onPressed: () {
                              Navigator.pop(context);
                              _confirmDelete(report);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      String title, String content, IconData icon, Color color,
      {bool multiline = false, VoidCallback? onTap}) {
    final card = Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
              ),
              maxLines: multiline ? null : 2,
              overflow: multiline ? null : TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }

  Future<void> _markAsResolved(ReportModel report) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);

      // Kiểm tra quyền admin từ thông tin người dùng
      if (userProvider.user == null || userProvider.user!.role != 'admin') {
        Navigator.pop(context); // Đóng dialog loading
        ToastHelper.showError(
            context, 'Bạn không có quyền thực hiện hành động này');
        return;
      }

      final success =
          await reportProvider.updateReportStatus(int.parse(report.id!), true);

      Navigator.pop(context); // Close loading dialog

      if (success) {
        ToastHelper.showSuccess(context, 'Đã đánh dấu báo cáo là đã xử lý');
      } else {
        ToastHelper.showError(context, 'Không thể cập nhật trạng thái báo cáo');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ToastHelper.showError(context, 'Đã xảy ra lỗi: $e');
    }
  }

  Future<void> _markAsUnresolved(ReportModel report) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);

      // Kiểm tra quyền admin từ thông tin người dùng
      if (userProvider.user == null || userProvider.user!.role != 'admin') {
        Navigator.pop(context); // Đóng dialog loading
        ToastHelper.showError(
            context, 'Bạn không có quyền thực hiện hành động này');
        return;
      }

      final success =
          await reportProvider.updateReportStatus(int.parse(report.id!), false);

      Navigator.pop(context); // Close loading dialog

      if (success) {
        ToastHelper.showSuccess(context, 'Đã đánh dấu báo cáo là chưa xử lý');
      } else {
        ToastHelper.showError(context, 'Không thể cập nhật trạng thái báo cáo');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ToastHelper.showError(context, 'Đã xảy ra lỗi: $e');
    }
  }

  void _confirmDelete(ReportModel report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa báo cáo này?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteReport(report);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReport(ReportModel report) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);

      // Kiểm tra quyền admin từ thông tin người dùng
      if (userProvider.user == null || userProvider.user!.role != 'admin') {
        Navigator.pop(context); // Đóng dialog loading
        ToastHelper.showError(
            context, 'Bạn không có quyền thực hiện hành động này');
        return;
      }

      final success = await reportProvider.deleteReport(int.parse(report.id!));

      Navigator.pop(context); // Close loading dialog

      if (success) {
        ToastHelper.showSuccess(context, 'Đã xóa báo cáo');
      } else {
        ToastHelper.showError(context, 'Không thể xóa báo cáo');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ToastHelper.showError(context, 'Đã xảy ra lỗi: $e');
    }
  }
}
