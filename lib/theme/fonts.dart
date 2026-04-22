import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NovaFonts {
  // Font cho các tiêu đề lớn, Logo - Inter bản Bold rất mạnh mẽ
  static TextStyle get heading => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  // Font cho nội dung số dư - Giữ Inter nhưng chỉnh weight để tạo sự khác biệt
  static TextStyle get numbers => GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5, 
  );

  // Font cho văn bản thông thường - Inter bản Regular cực kỳ dễ đọc
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
}