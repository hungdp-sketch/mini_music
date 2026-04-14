// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../blocs/player/player_cubit.dart';
// import '../../../services/lyrics/lyrics_service.dart';

// class LyricsPanel extends StatefulWidget {
//   const LyricsPanel({super.key});

//   @override
//   State<LyricsPanel> createState() => _LyricsPanelState();
// }

// class _LyricsPanelState extends State<LyricsPanel> {
//   late ScrollController _scrollController;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<PlayerCubit, PlayerCubitState>(
//       builder: (context, state) {
//         // final lyrics = state.lyrics;
//         final isLoading = state.lyricsLoading;
//         final currentPosition = state.position;

//         if (isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // if (lyrics == null || lyrics.lines.isEmpty) {
//         //   return Center(
//         //     child: Column(
//         //       mainAxisAlignment: MainAxisAlignment.center,
//         //       children: [
//         //         const Icon(
//         //           Icons.lyrics_outlined,
//         //           size: 48,
//         //           color: Colors.white54,
//         //         ),
//         //         const SizedBox(height: 16),
//         //         Text(
//         //           'Không có lời bài hát',
//         //           style: TextStyle(
//         //             color: Colors.white.withValues(alpha: 0.7),
//         //             fontSize: 16,
//         //           ),
//         //         ),
//         //         const SizedBox(height: 8),
//         //         ElevatedButton(
//         //           onPressed: () {
//         //             context.read<PlayerCubit>().loadLyrics();
//         //           },
//         //           child: const Text('Thử lại'),
//         //         ),
//         //       ],
//         //     ),
//         //   );
//         // }

//         // Find current lyric line using binary search
//         // final currentLineIndex = _findCurrentLineIndexBinary(
//         //   lyrics.lines,
//         //   currentPosition,
//         // );

//         // Auto-scroll to keep current line visible
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _autoScroll(currentLineIndex);
//         });

//         return ListView.builder(
//           controller: _scrollController,
//           padding: const EdgeInsets.symmetric(vertical: 40),
//           itemCount: lyrics.lines.length,
//           itemBuilder: (context, index) {
//             final line = lyrics.lines[index];
//             final isCurrent = index == currentLineIndex;
//             final isUpcoming = index == currentLineIndex + 1;
//             final isPast = index < currentLineIndex;

//             return Container(
//               margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               child: Text(
//                 line.text,
//                 style: TextStyle(
//                   fontSize: isCurrent ? 18 : (isUpcoming ? 16 : 14),
//                   fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
//                   color: isCurrent
//                       ? Colors.white
//                       : (isUpcoming
//                             ? Colors.white.withValues(alpha: 0.7)
//                             : Colors.white.withValues(
//                                 alpha: isPast ? 0.3 : 0.4,
//                               )),
//                   height: 1.6,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   /// Binary search to find current line index efficiently
//   int _findCurrentLineIndexBinary(List<LyricLine> lines, Duration position) {
//     if (lines.isEmpty) return 0;

//     int left = 0;
//     int right = lines.length - 1;
//     int result = 0;

//     while (left <= right) {
//       final mid = (left + right) ~/ 2;
//       if (lines[mid].timestamp <= position) {
//         result = mid;
//         left = mid + 1;
//       } else {
//         right = mid - 1;
//       }
//     }

//     return result.clamp(0, lines.length - 1);
//   }

//   /// Auto-scroll to keep current line visible in center
//   void _autoScroll(int currentLineIndex) {
//     if (!_scrollController.hasClients) return;

//     const itemHeight = 80.0;
//     final targetOffset =
//         currentLineIndex * itemHeight -
//         (_scrollController.position.viewportDimension / 2);

//     _scrollController.animateTo(
//       targetOffset
//           .clamp(0, _scrollController.position.maxScrollExtent)
//           .toDouble(),
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
// }
