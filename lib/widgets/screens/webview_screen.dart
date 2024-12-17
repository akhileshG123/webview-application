import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_application/widgets/providers/webview_provider.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _controller;
  bool _canGoBack = false;
  bool _canGoForward = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Track scroll position to enable/disable pull-to-refresh
  double _scrollPosition = 0;
  bool get _canPullToRefresh => _scrollPosition <= 0;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {
          context.read<WebViewProvider>().setLoading(true);
        },
        onPageFinished: (String url) {
          context.read<WebViewProvider>().setLoading(false);
          _updateNavigationButtons();

          // Inject JavaScript to track scroll position
          _controller.runJavaScript('''
            window.addEventListener('scroll', function() {
              window.webkit.messageHandlers.scrollHandler.postMessage(window.scrollY);
            });
          ''');
        },
        onWebResourceError: (WebResourceError error) {
          context.read<WebViewProvider>().setError(
              'Failed to load the page. Please check your internet connection.');
        },
      ))
      // Add JavaScript channel to receive scroll position updates
      ..addJavaScriptChannel(
        'scrollHandler',
        onMessageReceived: (JavaScriptMessage message) {
          setState(() {
            _scrollPosition = double.tryParse(message.message) ?? 0;
          });
        },
      );

    final selectedPlatform = context.read<WebViewProvider>().selectedPlatform;
    if (selectedPlatform != null) {
      _loadUrl(selectedPlatform.url);
    }
  }

  void _loadUrl(String url) {
    _controller.loadRequest(Uri.parse(url));
  }

  Future<void> _updateNavigationButtons() async {
    final canGoBack = await _controller.canGoBack();
    final canGoForward = await _controller.canGoForward();
    setState(() {
      _canGoBack = canGoBack;
      _canGoForward = canGoForward;
    });
  }

  Future<void> _handleRefresh() async {
    await _controller.reload();
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 71, 69, 69),
        automaticallyImplyLeading: false, // Disable automatic back button
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Back button
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(), // Remove minimum size constraints
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: _canGoBack
                  ? () {
                      _controller.goBack();
                      _updateNavigationButtons();
                    }
                  : null,
            ),
            // Forward button
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(), // Remove minimum size constraints
              icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 24),
              onPressed: _canGoForward
                  ? () {
                      _controller.goForward();
                      _updateNavigationButtons();
                    }
                  : null,
            ),
          ],
        ),
        titleSpacing: 0, // Remove default title spacing
        actions: [
          Consumer<WebViewProvider>(
            builder: (context, provider, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.selectedPlatform?.id,
                    onChanged: (String? platformId) {
                      if (platformId != null) {
                        final platform = provider.platforms
                            .firstWhere((p) => p.id == platformId);
                        provider.setSelectedPlatform(platform);
                        _loadUrl(platform.url);
                      }
                    },
                    items: provider.platforms
                        .map<DropdownMenuItem<String>>((platform) {
                      return DropdownMenuItem<String>(
                        value: platform.id,
                        child: Text(
                          platform.name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Consumer<WebViewProvider>(
        builder: (context, webViewProvider, child) {
          if (webViewProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    webViewProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      webViewProvider.setError(null);
                      _controller.reload();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _canPullToRefresh ? _handleRefresh : () async {},
                notificationPredicate: (notification) {
                  // Only allow pull-to-refresh when at the top of the page
                  return _canPullToRefresh;
                },
                child: WebViewWidget(controller: _controller),
              ),
              if (webViewProvider.isLoading)
                const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                ),
            ],
          );
        },
      ),
    );
  }
}