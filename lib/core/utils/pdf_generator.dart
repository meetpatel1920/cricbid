import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';

import '../constants/app_constants.dart';
import '../../features/auth/models/app_models.dart';

class PdfGenerator {
  // ── Auction PDF (1 player per page) ──────────────────────────────────────

  static Future<File> generateAuctionPdf({
    required List<PlayerModel> players,
    required String groupName,
    required int roundNumber,
  }) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd MMM yyyy').format(DateTime.now());

    for (final player in players) {
      // ── FIX: Load image via http.get, not broken networkImage() ──────────
      pw.MemoryImage? playerImage;
      if (player.photoUrl != null && player.photoUrl!.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(player.photoUrl!)).timeout(
                const Duration(seconds: 8),
              );
          if (response.statusCode == 200) {
            playerImage = pw.MemoryImage(response.bodyBytes);
          }
        } catch (_) {
          // Image load failed — continue without photo
        }
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#1A6B3C'),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        groupName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'PLAYER AUCTION — ROUND $roundNumber',
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: PdfColor.fromHex('#A7F3D0'),
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 24),

                // Player Number Badge
                pw.Container(
                  width: 80,
                  height: 80,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F59E0B'),
                    shape: pw.BoxShape.circle,
                  ),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '#${player.playerNumber}',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),

                pw.SizedBox(height: 20),

                // Player Photo
                if (playerImage != null) ...[
                  pw.Container(
                    width: 180,
                    height: 180,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(
                        color: PdfColor.fromHex('#1A6B3C'),
                        width: 4,
                      ),
                    ),
                    child: pw.ClipOval(
                      child: pw.Image(playerImage, fit: pw.BoxFit.cover),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                ],

                // Player Name
                pw.Text(
                  player.name.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#111827'),
                  ),
                ),

                pw.SizedBox(height: 8),

                // Type Badge
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: _typeColor(player.type),
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    player.type.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),

                pw.SizedBox(height: 24),

                // Info Grid
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F8F9FA'),
                    borderRadius: pw.BorderRadius.circular(12),
                    border: pw.Border.all(
                      color: PdfColor.fromHex('#DDE1E7'),
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      if (player.birthdate != null)
                        _infoRow(
                          'Date of Birth',
                          DateFormat('dd MMM yyyy').format(player.birthdate!),
                        ),
                      if (player.lastTeam != null && player.lastTeam!.isNotEmpty) ...[
                        pw.SizedBox(height: 8),
                        _infoRow('Last Team', player.lastTeam!),
                      ],
                      pw.SizedBox(height: 8),
                      _infoRow('Phone', player.phone),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Footer
                pw.Text(
                  'Generated by CricBid • $dateStr',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColor.fromHex('#9CA3AF'),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/auction_round${roundNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ── Timetable PDF ─────────────────────────────────────────────────────────

  static Future<File> generateTimetablePdf({
    required List<MatchModel> matches,
    required String groupName,
    required String timetableName,
  }) async {
    final pdf = pw.Document();

    // Group matches by date
    final Map<String, List<MatchModel>> byDate = {};
    for (final match in matches) {
      final key = DateFormat('dd MMM yyyy').format(match.scheduledAt);
      byDate.putIfAbsent(key, () => []).add(match);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF1A6B3C)),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    groupName,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1A6B3C'),
                    ),
                  ),
                  pw.Text(
                    timetableName,
                    style: pw.TextStyle(fontSize: 11, color: PdfColor.fromHex('#4B5563')),
                  ),
                ],
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#9CA3AF')),
              ),
            ],
          ),
        ),
        build: (context) {
          final widgets = <pw.Widget>[];

          byDate.forEach((date, dayMatches) {
            widgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 16, bottom: 8),
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#E8F5EE'),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  date,
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#1A6B3C'),
                  ),
                ),
              ),
            );

            for (final match in dayMatches) {
              widgets.add(
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromHex('#DDE1E7')),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 60,
                        child: pw.Column(
                          children: [
                            pw.Text(
                              DateFormat('HH:mm').format(match.scheduledAt),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 13,
                                color: PdfColor.fromHex('#1A6B3C'),
                              ),
                            ),
                            pw.Text(
                              'Match ${match.matchNumber}',
                              style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#9CA3AF')),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                match.team1Name,
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 8),
                              child: pw.Text(
                                'VS',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColor.fromHex('#9CA3AF'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                match.team2Name,
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: _stageColor(match.stage),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          _stageLabel(match.stage),
                          style: pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          });

          return widgets;
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/timetable_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ── Share PDF ─────────────────────────────────────────────────────────────

  static Future<void> sharePdf(File pdfFile, {String? subject}) async {
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      subject: subject ?? 'CricBid PDF',
    );
  }

  // ── Print PDF ─────────────────────────────────────────────────────────────

  static Future<void> printPdf(File pdfFile) async {
    await Printing.layoutPdf(
      onLayout: (_) async => pdfFile.readAsBytes(),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static pw.Widget _infoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          '$label: ',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#4B5563'),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColor.fromHex('#111827'),
          ),
        ),
      ],
    );
  }

  static PdfColor _typeColor(String type) {
    switch (type) {
      case AppConstants.typeBowling:
        return PdfColor.fromHex('#DC2626');
      case AppConstants.typeAllRounder:
        return PdfColor.fromHex('#7C3AED');
      default:
        return PdfColor.fromHex('#2563EB');
    }
  }

  static PdfColor _stageColor(String stage) {
    if (stage == 'final') return PdfColor.fromHex('#F59E0B');
    if (stage.contains('semi')) return PdfColor.fromHex('#7C3AED');
    return PdfColor.fromHex('#1A6B3C');
  }

  static String _stageLabel(String stage) {
    if (stage == 'final') return 'FINAL';
    if (stage.contains('semi')) return 'SEMI';
    return stage.toUpperCase().replaceAll('_', ' ');
  }
}

// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:share_plus/share_plus.dart';

// import '../constants/app_constants.dart';
// import '../../features/auth/models/app_models.dart';

// class PdfGenerator {
//   // ── Auction PDF (1 player per page) ──────────────────────────────────────

//   static Future<File> generateAuctionPdf({
//     required List<PlayerModel> players,
//     required String groupName,
//     required int roundNumber,
//   }) async {
//     final pdf = pw.Document();
//     final dateStr =
//         DateFormat('dd MMM yyyy').format(DateTime.now());

//     for (final player in players) {
//       // Load player image if available
//       pw.MemoryImage? playerImage;
//       if (player.photoUrl != null && player.photoUrl!.isNotEmpty) {
//         try {
//           final netImage =
//               await networkImage(player.photoUrl!);
//           playerImage = pw.MemoryImage(
//               (await netImage.resolve(const ImageConfiguration()))
//                   .toByteData(format: ui.ImageByteFormat.png)
//                   .then((b) => b!.buffer.asUint8List()) as Uint8List);
//         } catch (_) {
//           // No image, skip
//         }
//       }

//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4,
//           margin: const pw.EdgeInsets.all(32),
//           build: (pw.Context context) {
//             return pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.center,
//               children: [
//                 // Header
//                 pw.Container(
//                   width: double.infinity,
//                   padding: const pw.EdgeInsets.all(16),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColor.fromHex('#1A6B3C'),
//                     borderRadius: pw.BorderRadius.circular(12),
//                   ),
//                   child: pw.Column(
//                     children: [
//                       pw.Text(
//                         groupName.toUpperCase(),
//                         style: pw.TextStyle(
//                           fontSize: 14,
//                           fontWeight: pw.FontWeight.bold,
//                           color: PdfColors.white,
//                         ),
//                       ),
//                       pw.SizedBox(height: 4),
//                       pw.Text(
//                         'PLAYER AUCTION — ROUND $roundNumber',
//                         style: pw.TextStyle(
//                           fontSize: 11,
//                           color: PdfColor.fromHex('#A7F3D0'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 pw.SizedBox(height: 24),

//                 // Player Number Badge
//                 pw.Container(
//                   width: 80,
//                   height: 80,
//                   decoration: pw.BoxDecoration(
//                     color: PdfColor.fromHex('#F59E0B'),
//                     shape: pw.BoxShape.circle,
//                   ),
//                   alignment: pw.Alignment.center,
//                   child: pw.Text(
//                     '#${player.playerNumber}',
//                     style: pw.TextStyle(
//                       fontSize: 28,
//                       fontWeight: pw.FontWeight.bold,
//                       color: PdfColors.white,
//                     ),
//                   ),
//                 ),

//                 pw.SizedBox(height: 20),

//                 // Player Photo
//                 if (playerImage != null) ...[
//                   pw.Container(
//                     width: 180,
//                     height: 180,
//                     decoration: pw.BoxDecoration(
//                       shape: pw.BoxShape.circle,
//                       border: pw.Border.all(
//                         color: PdfColor.fromHex('#1A6B3C'),
//                         width: 4,
//                       ),
//                     ),
//                     child: pw.ClipOval(
//                       child: pw.Image(playerImage, fit: pw.BoxFit.cover),
//                     ),
//                   ),
//                   pw.SizedBox(height: 20),
//                 ],

//                 // Player Name
//                 pw.Text(
//                   player.name.toUpperCase(),
//                   style: pw.TextStyle(
//                     fontSize: 32,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColor.fromHex('#111827'),
//                   ),
//                 ),

//                 pw.SizedBox(height: 8),

//                 // Type Badge
//                 pw.Container(
//                   padding: const pw.EdgeInsets.symmetric(
//                       horizontal: 16, vertical: 6),
//                   decoration: pw.BoxDecoration(
//                     color: _typeColor(player.type),
//                     borderRadius: pw.BorderRadius.circular(20),
//                   ),
//                   child: pw.Text(
//                     player.type.toUpperCase(),
//                     style: pw.TextStyle(
//                       fontSize: 12,
//                       fontWeight: pw.FontWeight.bold,
//                       color: PdfColors.white,
//                     ),
//                   ),
//                 ),

//                 pw.SizedBox(height: 24),

//                 // Info Grid
//                 pw.Container(
//                   width: double.infinity,
//                   padding: const pw.EdgeInsets.all(20),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColor.fromHex('#F8F9FA'),
//                     borderRadius: pw.BorderRadius.circular(12),
//                     border: pw.Border.all(
//                       color: PdfColor.fromHex('#DDE1E7'),
//                     ),
//                   ),
//                   child: pw.Column(
//                     children: [
//                       if (player.birthdate != null)
//                         _infoRow(
//                           'Date of Birth',
//                           DateFormat('dd MMM yyyy')
//                               .format(player.birthdate!),
//                         ),
//                       if (player.lastTeam != null &&
//                           player.lastTeam!.isNotEmpty) ...[
//                         pw.SizedBox(height: 8),
//                         _infoRow('Last Team', player.lastTeam!),
//                       ],
//                       pw.SizedBox(height: 8),
//                       _infoRow('Phone', player.phone),
//                     ],
//                   ),
//                 ),

//                 pw.Spacer(),

//                 // Footer
//                 pw.Text(
//                   'Generated by CricBid • $dateStr',
//                   style: pw.TextStyle(
//                     fontSize: 9,
//                     color: PdfColor.fromHex('#9CA3AF'),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       );
//     }

//     final dir = await getTemporaryDirectory();
//     final file = File(
//         '${dir.path}/auction_round${roundNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf');
//     await file.writeAsBytes(await pdf.save());
//     return file;
//   }

//   // ── Timetable PDF ─────────────────────────────────────────────────────────

//   static Future<File> generateTimetablePdf({
//     required List<MatchModel> matches,
//     required String groupName,
//     required String timetableName,
//   }) async {
//     final pdf = pw.Document();

//     // Group matches by date
//     final Map<String, List<MatchModel>> byDate = {};
//     for (final match in matches) {
//       final key = DateFormat('dd MMM yyyy').format(match.scheduledAt);
//       byDate.putIfAbsent(key, () => []).add(match);
//     }

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(28),
//         header: (context) => pw.Container(
//           padding: const pw.EdgeInsets.only(bottom: 12),
//           decoration: const pw.BoxDecoration(
//             border: pw.Border(
//               bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF1A6B3C)),
//             ),
//           ),
//           child: pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     groupName,
//                     style: pw.TextStyle(
//                       fontSize: 16,
//                       fontWeight: pw.FontWeight.bold,
//                       color: PdfColor.fromHex('#1A6B3C'),
//                     ),
//                   ),
//                   pw.Text(
//                     timetableName,
//                     style: pw.TextStyle(
//                         fontSize: 11,
//                         color: PdfColor.fromHex('#4B5563')),
//                   ),
//                 ],
//               ),
//               pw.Text(
//                 'Page ${context.pageNumber} of ${context.pagesCount}',
//                 style: pw.TextStyle(
//                     fontSize: 9, color: PdfColor.fromHex('#9CA3AF')),
//               ),
//             ],
//           ),
//         ),
//         build: (context) {
//           final widgets = <pw.Widget>[];

//           byDate.forEach((date, dayMatches) {
//             widgets.add(
//               pw.Container(
//                 margin: const pw.EdgeInsets.only(top: 16, bottom: 8),
//                 padding:
//                     const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: pw.BoxDecoration(
//                   color: PdfColor.fromHex('#E8F5EE'),
//                   borderRadius: pw.BorderRadius.circular(6),
//                 ),
//                 child: pw.Text(
//                   date,
//                   style: pw.TextStyle(
//                     fontSize: 13,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColor.fromHex('#1A6B3C'),
//                   ),
//                 ),
//               ),
//             );

//             for (final match in dayMatches) {
//               widgets.add(
//                 pw.Container(
//                   margin: const pw.EdgeInsets.only(bottom: 6),
//                   padding: const pw.EdgeInsets.all(12),
//                   decoration: pw.BoxDecoration(
//                     border: pw.Border.all(
//                         color: PdfColor.fromHex('#DDE1E7')),
//                     borderRadius: pw.BorderRadius.circular(8),
//                   ),
//                   child: pw.Row(
//                     children: [
//                       pw.Container(
//                         width: 60,
//                         child: pw.Column(
//                           children: [
//                             pw.Text(
//                               DateFormat('HH:mm')
//                                   .format(match.scheduledAt),
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 fontSize: 13,
//                                 color:
//                                     PdfColor.fromHex('#1A6B3C'),
//                               ),
//                             ),
//                             pw.Text(
//                               'Match ${match.matchNumber}',
//                               style: pw.TextStyle(
//                                   fontSize: 9,
//                                   color:
//                                       PdfColor.fromHex('#9CA3AF')),
//                             ),
//                           ],
//                         ),
//                       ),
//                       pw.SizedBox(width: 12),
//                       pw.Expanded(
//                         child: pw.Row(
//                           mainAxisAlignment:
//                               pw.MainAxisAlignment.center,
//                           children: [
//                             pw.Expanded(
//                               child: pw.Text(
//                                 match.team1Name,
//                                 textAlign: pw.TextAlign.right,
//                                 style: pw.TextStyle(
//                                     fontWeight:
//                                         pw.FontWeight.bold,
//                                     fontSize: 12),
//                               ),
//                             ),
//                             pw.Padding(
//                               padding:
//                                   const pw.EdgeInsets.symmetric(
//                                       horizontal: 8),
//                               child: pw.Text(
//                                 'VS',
//                                 style: pw.TextStyle(
//                                   fontSize: 10,
//                                   color:
//                                       PdfColor.fromHex('#9CA3AF'),
//                                 ),
//                               ),
//                             ),
//                             pw.Expanded(
//                               child: pw.Text(
//                                 match.team2Name,
//                                 textAlign: pw.TextAlign.left,
//                                 style: pw.TextStyle(
//                                     fontWeight:
//                                         pw.FontWeight.bold,
//                                     fontSize: 12),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       pw.SizedBox(width: 12),
//                       pw.Container(
//                         padding: const pw.EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: pw.BoxDecoration(
//                           color: _stageColor(match.stage),
//                           borderRadius:
//                               pw.BorderRadius.circular(4),
//                         ),
//                         child: pw.Text(
//                           _stageLabel(match.stage),
//                           style: pw.TextStyle(
//                               fontSize: 8,
//                               color: PdfColors.white,
//                               fontWeight: pw.FontWeight.bold),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//           });

//           return widgets;
//         },
//       ),
//     );

//     final dir = await getTemporaryDirectory();
//     final file = File(
//         '${dir.path}/timetable_${DateTime.now().millisecondsSinceEpoch}.pdf');
//     await file.writeAsBytes(await pdf.save());
//     return file;
//   }

//   // ── Share PDF ─────────────────────────────────────────────────────────────

//   static Future<void> sharePdf(File pdfFile, {String? subject}) async {
//     await Share.shareXFiles(
//       [XFile(pdfFile.path)],
//       subject: subject ?? 'CricBid PDF',
//     );
//   }

//   // ── Print PDF ─────────────────────────────────────────────────────────────

//   static Future<void> printPdf(File pdfFile) async {
//     await Printing.layoutPdf(
//       onLayout: (_) async => pdfFile.readAsBytes(),
//     );
//   }

//   // ── Helpers ───────────────────────────────────────────────────────────────

//   static pw.Widget _infoRow(String label, String value) {
//     return pw.Row(
//       children: [
//         pw.Text(
//           '$label: ',
//           style: pw.TextStyle(
//             fontSize: 12,
//             fontWeight: pw.FontWeight.bold,
//             color: PdfColor.fromHex('#4B5563'),
//           ),
//         ),
//         pw.Text(
//           value,
//           style: pw.TextStyle(
//             fontSize: 12,
//             color: PdfColor.fromHex('#111827'),
//           ),
//         ),
//       ],
//     );
//   }

//   static PdfColor _typeColor(String type) {
//     switch (type) {
//       case AppConstants.typeBowling:
//         return PdfColor.fromHex('#DC2626');
//       case AppConstants.typeAllRounder:
//         return PdfColor.fromHex('#7C3AED');
//       default:
//         return PdfColor.fromHex('#2563EB');
//     }
//   }

//   static PdfColor _stageColor(String stage) {
//     if (stage == 'final') return PdfColor.fromHex('#F59E0B');
//     if (stage.contains('semi')) return PdfColor.fromHex('#7C3AED');
//     return PdfColor.fromHex('#1A6B3C');
//   }

//   static String _stageLabel(String stage) {
//     if (stage == 'final') return 'FINAL';
//     if (stage.contains('semi')) return 'SEMI';
//     return stage.toUpperCase().replaceAll('_', ' ');
//   }
// }

// // Dummy import to avoid compile error in stub
// // ignore: avoid_web_libraries_in_flutter
// import 'dart:ui' as ui;
// Future<NetworkImage> networkImage(String url) async =>
//     NetworkImage(url);
