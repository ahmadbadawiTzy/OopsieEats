#!/usr/bin/env python3
"""
Generate publication-quality SVG diagrams and high-resolution PNGs
for NutriView Business Requirements Document (BRD) & Project Report.
Standards: Strict UML notation, clean academic palette, zero overlaps.
"""

import os
import subprocess

OUTPUT_DIR = "docs/brd/diagram"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def render_svg_to_png(svg_path, png_path, width, height):
    """Render SVG to crisp PNG using headless browser with exact bounding viewport."""
    html_wrapper = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{ width: {width}px; height: {height}px; overflow: hidden; background: #ffffff; }}
</style>
</head>
<body>
<img src="{os.path.basename(svg_path)}" width="{width}" height="{height}" style="display:block;" />
</body>
</html>"""
    html_path = svg_path.replace(".svg", ".html")
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html_wrapper)

    cmd = [
        "brave-browser", "--headless", "--disable-gpu",
        f"--window-size={width},{height}",
        f"--screenshot={png_path}",
        html_path
    ]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if os.path.exists(html_path):
        os.remove(html_path)
    print(f"Rendered: {png_path} ({width}x{height})")


# ==========================================
# 1. System Architecture Diagram
# ==========================================
def generate_system_architecture():
    w, h = 1100, 680
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <defs>
    <marker id="arr-blue" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#2563EB"/>
    </marker>
    <marker id="arr-slate" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#475569"/>
    </marker>
    <filter id="shadow" x="-3%" y="-3%" width="106%" height="106%">
      <feDropShadow dx="2" dy="2" stdDeviation="2" flood-color="#0F172A" flood-opacity="0.08"/>
    </filter>
  </defs>

  <!-- Canvas Background -->
  <rect width="{w}" height="{h}" fill="#F8FAFC"/>
  <rect x="15" y="15" width="{w-30}" height="{h-30}" rx="10" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>

  <!-- Diagram Title Header -->
  <rect x="15" y="15" width="{w-30}" height="55" rx="10" fill="#0F172A"/>
  <rect x="15" y="55" width="{w-30}" height="15" fill="#0F172A"/>
  <text x="35" y="48" font-family="system-ui, sans-serif" font-size="18" font-weight="700" fill="#FFFFFF">NutriView — High-Level System Architecture</text>
  <text x="{w-35}" y="48" font-family="system-ui, sans-serif" font-size="13" font-weight="500" fill="#94A3B8" text-anchor="end">Edge-AI On-Device &amp; Serverless Cloud</text>

  <!-- Left: Client Device Boundary (Flutter App) -->
  <rect x="40" y="90" width="650" height="565" rx="8" fill="#F8FAFC" stroke="#0284C7" stroke-width="2" filter="url(#shadow)"/>
  <rect x="40" y="90" width="650" height="34" rx="8" fill="#E0F2FE"/>
  <rect x="40" y="114" width="650" height="10" fill="#E0F2FE"/>
  <text x="55" y="113" font-family="system-ui, sans-serif" font-size="14" font-weight="700" fill="#0369A1">CLIENT TIER: Android Mobile Device (Flutter Application Runtime)</text>

  <!-- Layer 1: Presentation Layer -->
  <rect x="60" y="138" width="610" height="96" rx="6" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>
  <text x="75" y="158" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#0F172A">PRESENTATION LAYER (Overkill Neo-Brutalism UI &amp; Responsive Widgets)</text>
  <g transform="translate(75, 168)">
    <rect x="0" y="0" width="135" height="52" rx="4" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.2"/>
    <text x="67" y="22" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#1E40AF" text-anchor="middle">Auth &amp; Splash</text>
    <text x="67" y="38" font-family="system-ui, sans-serif" font-size="9" fill="#3B82F6" text-anchor="middle">Login, Register, Gate</text>

    <rect x="145" y="0" width="140" height="52" rx="4" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.2"/>
    <text x="215" y="22" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#1E40AF" text-anchor="middle">Daily Dashboard</text>
    <text x="215" y="38" font-family="system-ui, sans-serif" font-size="9" fill="#3B82F6" text-anchor="middle">Calorie Dial, Macro Bento</text>

    <rect x="295" y="0" width="140" height="52" rx="4" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.2"/>
    <text x="365" y="22" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#1E40AF" text-anchor="middle">Scanner &amp; Log</text>
    <text x="365" y="38" font-family="system-ui, sans-serif" font-size="9" fill="#3B82F6" text-anchor="middle">Camera, Confirm, Portion</text>

    <rect x="445" y="0" width="135" height="52" rx="4" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.2"/>
    <text x="512" y="22" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#1E40AF" text-anchor="middle">Admin &amp; Articles</text>
    <text x="512" y="38" font-family="system-ui, sans-serif" font-size="9" fill="#3B82F6" text-anchor="middle">CMS Portal, Catalog, Bio</text>
  </g>

  <!-- Layer 2: Business Logic & State Layer -->
  <rect x="60" y="246" width="610" height="96" rx="6" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>
  <text x="75" y="266" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#0F172A">BUSINESS LOGIC &amp; STATE MANAGEMENT (Provider Pattern &amp; Deterministic Engine)</text>
  <g transform="translate(75, 276)">
    <rect x="0" y="0" width="280" height="52" rx="4" fill="#ECFDF5" stroke="#10B981" stroke-width="1.2"/>
    <text x="140" y="22" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#065F46" text-anchor="middle">Feature Providers (ChangeNotifier)</text>
    <text x="140" y="38" font-family="system-ui, sans-serif" font-size="9" fill="#047857" text-anchor="middle">AuthProvider, DashboardProvider, ScanFlowProvider</text>

    <rect x="300" y="0" width="280" height="52" rx="4" fill="#ECFDF5" stroke="#10B981" stroke-width="1.2"/>
    <text x="440" y="22" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#065F46" text-anchor="middle">Deterministic Nutrition Calculator</text>
    <text x="440" y="38" font-family="system-ui, sans-serif" font-size="9" fill="#047857" text-anchor="middle">Mifflin-St Jeor (BMR/TDEE) &amp; Atwater Factor Cross-Check</text>
  </g>

  <!-- Layer 3: Edge AI & Vision Subsystem (100% On-Device) -->
  <rect x="60" y="354" width="610" height="136" rx="6" fill="#FFFBEB" stroke="#F59E0B" stroke-width="1.5"/>
  <text x="75" y="374" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#B45309">EDGE AI &amp; COMPUTER VISION SUBSYSTEM (100% On-Device, Privacy-Preserving)</text>
  
  <rect x="75" y="384" width="170" height="92" rx="4" fill="#FFFFFF" stroke="#FBBF24" stroke-width="1.2"/>
  <text x="160" y="404" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#92400E" text-anchor="middle">Background Worker Isolate</text>
  <text x="160" y="420" font-family="system-ui, sans-serif" font-size="9" fill="#78350F" text-anchor="middle">• Image Decoding</text>
  <text x="160" y="434" font-family="system-ui, sans-serif" font-size="9" fill="#78350F" text-anchor="middle">• EXIF Orientation Baking</text>
  <text x="160" y="448" font-family="system-ui, sans-serif" font-size="9" fill="#78350F" text-anchor="middle">• Linear Resize 640x640</text>
  <text x="160" y="462" font-family="system-ui, sans-serif" font-size="9" fill="#78350F" text-anchor="middle">• Float32 Channel Norm</text>

  <rect x="260" y="384" width="210" height="92" rx="4" fill="#FFFFFF" stroke="#FBBF24" stroke-width="1.2"/>
  <text x="365" y="404" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#92400E" text-anchor="middle">YOLO26n Neural Inference</text>
  <text x="365" y="420" font-family="system-ui, sans-serif" font-size="9" fill="#78350F" text-anchor="middle">• tflite_flutter v0.12.1 (C++ Engine)</text>
  <text x="365" y="434" font-family="system-ui, sans-serif" font-size="9" fill="#78350F" text-anchor="middle">• Quantized best.tflite (9.4 MB)</text>
  <text x="365" y="448" font-family="system-ui, sans-serif" font-size="9" fill="#78350F" text-anchor="middle">• 29 Indonesian Food Classes</text>
  <text x="365" y="462" font-family="system-ui, sans-serif" font-size="9" fill="#78350F" text-anchor="middle">• Multi-threaded CPU Exec (4 cores)</text>

  <rect x="485" y="384" width="170" height="92" rx="4" fill="#FFFFFF" stroke="#FBBF24" stroke-width="1.2"/>
  <text x="570" y="404" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#92400E" text-anchor="middle">Postprocessing &amp; NMS</text>
  <text x="570" y="420" font-family="system-ui, sans-serif" font-size="9" fill="#78350F" text-anchor="middle">• [1, 33, 8400] Tensor Parsing</text>
  <text x="570" y="434" font-family="system-ui, sans-serif" font-size="9" fill="#78350F" text-anchor="middle">• Array Hoisting Optimization</text>
  <text x="570" y="448" font-family="system-ui, sans-serif" font-size="9" fill="#78350F" text-anchor="middle">• IoU 0.45 Overlap Filter</text>
  <text x="570" y="462" font-family="system-ui, sans-serif" font-size="9" fill="#78350F" text-anchor="middle">• Score Thresh 0.15 / 0.30</text>

  <!-- Layer 4: Data Layer & Local Persistence -->
  <rect x="60" y="502" width="610" height="136" rx="6" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>
  <text x="75" y="522" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#0F172A">DATA ACCESS &amp; OFFLINE PERSISTENCE LAYER</text>
  <g transform="translate(75, 532)">
    <rect x="0" y="0" width="180" height="92" rx="4" fill="#F1F5F9" stroke="#64748B" stroke-width="1.2"/>
    <text x="90" y="20" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#334155" text-anchor="middle">Repository Pattern</text>
    <text x="90" y="38" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">Auth, Profile, Food,</text>
    <text x="90" y="52" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">Meal, Article, Admin Repos</text>
    <text x="90" y="70" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">ApiClient (Session Manager)</text>

    <rect x="195" y="0" width="185" height="92" rx="4" fill="#F1F5F9" stroke="#64748B" stroke-width="1.2"/>
    <text x="287" y="20" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#334155" text-anchor="middle">Hardware Keystore / Keychain</text>
    <text x="287" y="38" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">flutter_secure_storage v9.2.2</text>
    <text x="287" y="52" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">• Firebase Auth UID &amp; Role</text>
    <text x="287" y="66" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">• Biometric Opt-in State</text>
    <text x="287" y="80" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">• Hardware-backed AES Encr.</text>

    <rect x="395" y="0" width="185" height="92" rx="4" fill="#F1F5F9" stroke="#64748B" stroke-width="1.2"/>
    <text x="487" y="20" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#334155" text-anchor="middle">Offline Bounded Cache</text>
    <text x="487" y="38" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">Firestore SQLite 100MB Cache</text>
    <text x="487" y="52" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">• Seed Foods Catalog Fallback</text>
    <text x="487" y="66" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">• Offline Mutation Queues</text>
    <text x="487" y="80" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">• Zero Crash when Airplaned</text>
  </g>

  <!-- Right: Backend Cloud Tier Boundary (Firebase Spark $0) -->
  <rect x="740" y="90" width="320" height="565" rx="8" fill="#F8FAFC" stroke="#D97706" stroke-width="2" filter="url(#shadow)"/>
  <rect x="740" y="90" width="320" height="34" rx="8" fill="#FEF3C7"/>
  <rect x="740" y="114" width="320" height="10" fill="#FEF3C7"/>
  <text x="755" y="113" font-family="system-ui, sans-serif" font-size="14" font-weight="700" fill="#92400E">CLOUD BACKEND: Google Firebase ($0)</text>

  <!-- Cloud Service 1: Firebase Auth -->
  <rect x="760" y="140" width="280" height="100" rx="6" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>
  <text x="775" y="162" font-family="system-ui, sans-serif" font-size="13" font-weight="700" fill="#0F172A">Firebase Authentication</text>
  <text x="775" y="182" font-family="system-ui, sans-serif" font-size="10" fill="#475569">• Email &amp; Password Provider</text>
  <text x="775" y="198" font-family="system-ui, sans-serif" font-size="10" fill="#475569">• Google Sign-In (OAuth 2.0)</text>
  <text x="775" y="214" font-family="system-ui, sans-serif" font-size="10" fill="#475569">• Official ID Verification Email (setLang 'id')</text>
  <text x="775" y="230" font-family="system-ui, sans-serif" font-size="10" fill="#475569">• Cryptographic JWT &amp; Auth Tokens</text>

  <!-- Cloud Service 2: Cloud Firestore -->
  <rect x="760" y="255" width="280" height="215" rx="6" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>
  <text x="775" y="277" font-family="system-ui, sans-serif" font-size="13" font-weight="700" fill="#0F172A">Cloud Firestore NoSQL Database</text>
  <text x="775" y="293" font-family="system-ui, sans-serif" font-size="10" font-weight="600" fill="#0369A1">Region: asia-southeast2 (Jakarta &lt; 50ms)</text>
  
  <rect x="775" y="303" width="250" height="152" rx="4" fill="#F8FAFC" stroke="#E2E8F0" stroke-width="1"/>
  <text x="785" y="322" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#334155">• users/{{userId}} (Profile &amp; Target)</text>
  <text x="785" y="340" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#059669">  └── /meals/{{id}} (Private Subcollection)</text>
  <text x="785" y="358" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#334155">• foods/{{id}} (TKPI 2020 Master Catalog)</text>
  <text x="785" y="376" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#334155">• cms_articles/{{id}} (Nutrition Articles)</text>
  <text x="785" y="394" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#334155">• cms_categories/{{id}} &amp; announcements</text>
  <text x="785" y="412" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#B91C1C">• cms_audit_logs/{{id}} (Immutable Logs)</text>
  <text x="785" y="430" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#334155">• cms_media/{{id}} (External Media URLs)</text>
  <text x="785" y="446" font-family="system-ui, sans-serif" font-size="9" font-style="italic" fill="#64748B">Zero Firebase Storage Bucket Dependency</text>

  <!-- Cloud Service 3: Declarative Security Rules -->
  <rect x="760" y="485" width="280" height="153" rx="6" fill="#FEF2F2" stroke="#EF4444" stroke-width="1.5"/>
  <text x="775" y="507" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#991B1B">Declarative Rules (firestore.rules)</text>
  <text x="775" y="525" font-family="system-ui, sans-serif" font-size="10" fill="#7F1D1D">• Strict 2-Role System ('admin' vs 'user')</text>
  <text x="775" y="541" font-family="system-ui, sans-serif" font-size="10" fill="#7F1D1D">• Anti-Privilege Escalation on create/update</text>
  <text x="775" y="557" font-family="system-ui, sans-serif" font-size="10" fill="#7F1D1D">• Multi-Tenant Isolation (isOwner check)</text>
  <text x="775" y="573" font-family="system-ui, sans-serif" font-size="10" fill="#7F1D1D">• Immutable Audit Logs (no update/delete)</text>
  <text x="775" y="589" font-family="system-ui, sans-serif" font-size="10" fill="#7F1D1D">• Default Deny: match /{{document=**}}</text>
  <text x="775" y="605" font-family="system-ui, sans-serif" font-size="10" fill="#7F1D1D">• 4 Composite Indexes (Date, Sort)</text>
  <text x="775" y="621" font-family="system-ui, sans-serif" font-size="9" font-weight="600" fill="#DC2626">Enforced natively on Firestore server layer</text>

  <!-- Connection Bridge Line between Client and Cloud -->
  <line x1="690" y1="210" x2="740" y2="210" stroke="#2563EB" stroke-width="2" marker-end="url(#arr-blue)"/>
  <line x1="740" y1="180" x2="690" y2="180" stroke="#2563EB" stroke-width="2" marker-end="url(#arr-blue)"/>

  <line x1="690" y1="360" x2="740" y2="360" stroke="#2563EB" stroke-width="2" marker-end="url(#arr-blue)"/>
  <line x1="740" y1="330" x2="690" y2="330" stroke="#2563EB" stroke-width="2" marker-end="url(#arr-blue)"/>

  <rect x="670" y="240" width="90" height="48" rx="4" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.2"/>
  <text x="715" y="258" font-family="system-ui, sans-serif" font-size="9" font-weight="700" fill="#1E40AF" text-anchor="middle">Direct SDK</text>
  <text x="715" y="272" font-family="system-ui, sans-serif" font-size="8" fill="#2563EB" text-anchor="middle">TLS 1.3 / gRPC</text>
</svg>"""
    svg_path = os.path.join(OUTPUT_DIR, "fig1_system_architecture.svg")
    png_path = os.path.join(OUTPUT_DIR, "fig1_system_architecture.png")
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(svg)
    render_svg_to_png(svg_path, png_path, w, h)


# ==========================================
# 2. Deployment Architecture Diagram
# ==========================================
def generate_deployment_architecture():
    w, h = 1050, 580
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <defs>
    <marker id="arr-gray" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#334155"/>
    </marker>
    <filter id="shadow" x="-3%" y="-3%" width="106%" height="106%">
      <feDropShadow dx="2" dy="2" stdDeviation="2" flood-color="#0F172A" flood-opacity="0.08"/>
    </filter>
  </defs>

  <rect width="{w}" height="{h}" fill="#F8FAFC"/>
  <rect x="15" y="15" width="{w-30}" height="{h-30}" rx="10" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>

  <!-- Title Header -->
  <rect x="15" y="15" width="{w-30}" height="55" rx="10" fill="#0F172A"/>
  <rect x="15" y="55" width="{w-30}" height="15" fill="#0F172A"/>
  <text x="35" y="48" font-family="system-ui, sans-serif" font-size="18" font-weight="700" fill="#FFFFFF">NutriView — UML Deployment Architecture Diagram</text>
  <text x="{w-35}" y="48" font-family="system-ui, sans-serif" font-size="13" font-weight="500" fill="#94A3B8" text-anchor="end">Production Target Environment</text>

  <!-- Node 1: Android Physical Mobile Device -->
  <g transform="translate(40, 95)" filter="url(#shadow)">
    <!-- Node 3D Box Header -->
    <path d="M 0 16 L 16 0 L 396 0 L 380 16 Z" fill="#E2E8F0" stroke="#475569" stroke-width="1.5"/>
    <path d="M 380 16 L 396 0 L 396 424 L 380 440 Z" fill="#CBD5E1" stroke="#475569" stroke-width="1.5"/>
    <rect x="0" y="16" width="380" height="424" rx="4" fill="#F8FAFC" stroke="#475569" stroke-width="1.5"/>
    
    <text x="20" y="42" font-family="system-ui, sans-serif" font-size="13" font-weight="700" fill="#0F172A">&lt;&lt;device&gt;&gt; Android Mobile Device</text>
    <text x="20" y="58" font-family="system-ui, sans-serif" font-size="10" fill="#475569">OS: Android 10+ (API Level 29 s/d 34) • ARM64 / x86_64</text>
    
    <!-- Execution Environment -->
    <rect x="15" y="70" width="350" height="355" rx="4" fill="#FFFFFF" stroke="#94A3B8" stroke-width="1.2"/>
    <text x="25" y="90" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#0369A1">&lt;&lt;execution environment&gt;&gt; Android Runtime (ART) / Flutter</text>

    <!-- Artifact: Application Bundle -->
    <rect x="25" y="105" width="330" height="65" rx="4" fill="#F0FDF4" stroke="#16A34A" stroke-width="1.2"/>
    <text x="35" y="125" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#14532D">&lt;&lt;artifact&gt;&gt; app-release.apk / .aab (57.8 MB)</text>
    <text x="35" y="141" font-family="system-ui, sans-serif" font-size="9.5" fill="#166534">• Flutter SDK 3.24+ / Dart 3.5+</text>
    <text x="35" y="155" font-family="system-ui, sans-serif" font-size="9.5" fill="#166534">• ProGuard R8 Code Shrinking &amp; Resource Stripping</text>

    <!-- Artifact: Edge AI Model -->
    <rect x="25" y="180" width="330" height="75" rx="4" fill="#FFFBEB" stroke="#D97706" stroke-width="1.2"/>
    <text x="35" y="200" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#92400E">&lt;&lt;artifact&gt;&gt; best.tflite (9.4 MB) &amp; classes.txt</text>
    <text x="35" y="216" font-family="system-ui, sans-serif" font-size="9.5" fill="#78350F">• YOLO26n Neural Network Model (29 Classes)</text>
    <text x="35" y="230" font-family="system-ui, sans-serif" font-size="9.5" fill="#78350F">• AAPT noCompress('tflite') — zero uncompress memory overhead</text>
    <text x="35" y="244" font-family="system-ui, sans-serif" font-size="9.5" fill="#78350F">• Executed via tflite_flutter C++ dynamic library</text>

    <!-- Artifact: Secure KeyStore -->
    <rect x="25" y="265" width="330" height="65" rx="4" fill="#EFF6FF" stroke="#2563EB" stroke-width="1.2"/>
    <text x="35" y="285" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#1E40AF">&lt;&lt;artifact&gt;&gt; Android KeyStore &amp; EncryptedPrefs</text>
    <text x="35" y="301" font-family="system-ui, sans-serif" font-size="9.5" fill="#1D4ED8">• flutter_secure_storage hardware-backed encryption</text>
    <text x="35" y="315" font-family="system-ui, sans-serif" font-size="9.5" fill="#1D4ED8">• Stores Auth UID, Role, and Biometric Keys</text>

    <!-- Artifact: Local Bounded Cache -->
    <rect x="25" y="340" width="330" height="70" rx="4" fill="#F8FAFC" stroke="#64748B" stroke-width="1.2"/>
    <text x="35" y="360" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#334155">&lt;&lt;artifact&gt;&gt; Cloud Firestore SQLite Local Cache</text>
    <text x="35" y="376" font-family="system-ui, sans-serif" font-size="9.5" fill="#475569">• 100 MB Bounded LRU Cache (cacheSizeBytes: 104857600)</text>
    <text x="35" y="390" font-family="system-ui, sans-serif" font-size="9.5" fill="#475569">• Fallback asset seed_foods.json (29 local items)</text>
    <text x="35" y="404" font-family="system-ui, sans-serif" font-size="9.5" fill="#475569">• Offline mutation write queue</text>
  </g>

  <!-- Node 2: Distribution Platform (Google Play Store) -->
  <g transform="translate(440, 115)" filter="url(#shadow)">
    <path d="M 0 16 L 16 0 L 226 0 L 210 16 Z" fill="#E2E8F0" stroke="#475569" stroke-width="1.5"/>
    <path d="M 210 16 L 226 0 L 226 154 L 210 170 Z" fill="#CBD5E1" stroke="#475569" stroke-width="1.5"/>
    <rect x="0" y="16" width="210" height="154" rx="4" fill="#F8FAFC" stroke="#475569" stroke-width="1.5"/>

    <text x="15" y="40" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#0F172A">&lt;&lt;distribution&gt;&gt;</text>
    <text x="15" y="56" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#047857">Google Play Store</text>

    <rect x="15" y="70" width="180" height="85" rx="4" fill="#FFFFFF" stroke="#94A3B8" stroke-width="1.2"/>
    <text x="25" y="90" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#334155">Play Console Pipeline:</text>
    <text x="25" y="106" font-family="system-ui, sans-serif" font-size="9" fill="#475569">• Android App Bundle (.aab)</text>
    <text x="25" y="120" font-family="system-ui, sans-serif" font-size="9" fill="#475569">• Play App Signing (KMS)</text>
    <text x="25" y="134" font-family="system-ui, sans-serif" font-size="9" fill="#475569">• Target SDK 36 Compliance</text>
    <text x="25" y="148" font-family="system-ui, sans-serif" font-size="9" fill="#475569">• Split APK per Device ABI</text>
  </g>

  <!-- Node 3: Cloud Infrastructure (Google Cloud / Firebase) -->
  <g transform="translate(685, 95)" filter="url(#shadow)">
    <path d="M 0 16 L 16 0 L 336 0 L 320 16 Z" fill="#E2E8F0" stroke="#475569" stroke-width="1.5"/>
    <path d="M 320 16 L 336 0 L 336 424 L 320 440 Z" fill="#CBD5E1" stroke="#475569" stroke-width="1.5"/>
    <rect x="0" y="16" width="320" height="424" rx="4" fill="#F8FAFC" stroke="#475569" stroke-width="1.5"/>

    <text x="20" y="42" font-family="system-ui, sans-serif" font-size="13" font-weight="700" fill="#0F172A">&lt;&lt;cloud serverless&gt;&gt;</text>
    <text x="20" y="58" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#B45309">Firebase Spark Plan ($0/month)</text>
    <text x="20" y="74" font-family="system-ui, sans-serif" font-size="9.5" fill="#475569">Region: asia-southeast2 (Jakarta)</text>

    <!-- Cloud Service: Firebase Auth -->
    <rect x="15" y="85" width="290" height="85" rx="4" fill="#FFFFFF" stroke="#F59E0B" stroke-width="1.2"/>
    <text x="25" y="105" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#92400E">&lt;&lt;service&gt;&gt; Firebase Authentication</text>
    <text x="25" y="121" font-family="system-ui, sans-serif" font-size="9.5" fill="#78350F">• Email/Password &amp; Google Sign-In</text>
    <text x="25" y="135" font-family="system-ui, sans-serif" font-size="9.5" fill="#78350F">• JWT ID Token Generation &amp; Refresh</text>
    <text x="25" y="149" font-family="system-ui, sans-serif" font-size="9.5" fill="#78350F">• Indonesian Email Templates ('id')</text>
    <text x="25" y="163" font-family="system-ui, sans-serif" font-size="9.5" fill="#78350F">• Secure Session Lifetime Management</text>

    <!-- Cloud Service: Firestore Engine -->
    <rect x="15" y="180" width="290" height="150" rx="4" fill="#FFFFFF" stroke="#0284C7" stroke-width="1.2"/>
    <text x="25" y="200" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#0369A1">&lt;&lt;service&gt;&gt; Cloud Firestore NoSQL</text>
    <text x="25" y="216" font-family="system-ui, sans-serif" font-size="9.5" fill="#075985">• Multi-Tenant Documents &amp; Collections</text>
    <text x="25" y="230" font-family="system-ui, sans-serif" font-size="9.5" fill="#075985">• Subcollections: users/{{uid}}/meals/{{id}}</text>
    <text x="25" y="244" font-family="system-ui, sans-serif" font-size="9.5" fill="#075985">• 4 Composite Query Indexes</text>
    <text x="25" y="258" font-family="system-ui, sans-serif" font-size="9.5" fill="#075985">• Read: 50K/day free tier quota</text>
    <text x="25" y="272" font-family="system-ui, sans-serif" font-size="9.5" fill="#075985">• Write: 20K/day free tier quota</text>
    <text x="25" y="286" font-family="system-ui, sans-serif" font-size="9.5" fill="#075985">• Delete: 20K/day free tier quota</text>
    <text x="25" y="300" font-family="system-ui, sans-serif" font-size="9.5" fill="#075985">• 1 GiB total storage capacity</text>
    <text x="25" y="316" font-family="system-ui, sans-serif" font-size="9.5" font-weight="600" fill="#0284C7">• Zero Firebase Storage Bucket!</text>

    <!-- Cloud Service: Rules Engine -->
    <rect x="15" y="340" width="290" height="85" rx="4" fill="#FEF2F2" stroke="#EF4444" stroke-width="1.2"/>
    <text x="25" y="360" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#991B1B">&lt;&lt;security&gt;&gt; firestore.rules Engine</text>
    <text x="25" y="376" font-family="system-ui, sans-serif" font-size="9.5" fill="#7F1D1D">• Strict 2-Role System ('admin' vs 'user')</text>
    <text x="25" y="390" font-family="system-ui, sans-serif" font-size="9.5" fill="#7F1D1D">• Declarative Role &amp; Owner Verification</text>
    <text x="25" y="404" font-family="system-ui, sans-serif" font-size="9.5" fill="#7F1D1D">• Immutable Audit Logs Enforcement</text>
    <text x="25" y="418" font-family="system-ui, sans-serif" font-size="9.5" fill="#7F1D1D">• Server-side Evaluation (0 Client Bypass)</text>
  </g>

  <!-- Connection Links -->
  <!-- Play Store -> Device (Distribution) -->
  <path fill="none" d="M 440 200 L 400 200" stroke="#047857" stroke-width="2" stroke-dasharray="6 3" marker-end="url(#arr-gray)"/>
  <text x="420" y="190" font-family="system-ui, sans-serif" font-size="9" font-weight="600" fill="#047857" text-anchor="middle">installs / updates</text>

  <!-- Device -> Firebase Cloud (TLS Direct SDK) -->
  <path fill="none" d="M 400 320 L 685 320" stroke="#2563EB" stroke-width="2" marker-end="url(#arr-gray)"/>
  <path fill="none" d="M 685 340 L 400 340" stroke="#2563EB" stroke-width="2" marker-end="url(#arr-gray)"/>
  <rect x="470" y="312" width="150" height="36" rx="4" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.2"/>
  <text x="545" y="327" font-family="system-ui, sans-serif" font-size="9.5" font-weight="700" fill="#1E40AF" text-anchor="middle">Direct Firebase SDK</text>
  <text x="545" y="341" font-family="system-ui, sans-serif" font-size="8.5" fill="#2563EB" text-anchor="middle">HTTPS / TLS 1.3 / gRPC</text>
</svg>"""
    svg_path = os.path.join(OUTPUT_DIR, "fig1b_deployment_architecture.svg")
    png_path = os.path.join(OUTPUT_DIR, "fig1b_deployment_architecture.png")
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(svg)
    render_svg_to_png(svg_path, png_path, w, h)


# ==========================================
# 3. Use Case Diagram
# ==========================================
def generate_use_case_diagram():
    w, h = 1150, 720
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <defs>
    <marker id="arr-arrow" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#475569"/>
    </marker>
    <filter id="shadow" x="-3%" y="-3%" width="106%" height="106%">
      <feDropShadow dx="2" dy="2" stdDeviation="2" flood-color="#0F172A" flood-opacity="0.08"/>
    </filter>
  </defs>

  <rect width="{w}" height="{h}" fill="#F8FAFC"/>
  <rect x="15" y="15" width="{w-30}" height="{h-30}" rx="10" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>

  <!-- Title Header -->
  <rect x="15" y="15" width="{w-30}" height="55" rx="10" fill="#0F172A"/>
  <rect x="15" y="55" width="{w-30}" height="15" fill="#0F172A"/>
  <text x="35" y="48" font-family="system-ui, sans-serif" font-size="18" font-weight="700" fill="#FFFFFF">NutriView — UML Standard Use Case Diagram</text>
  <text x="{w-35}" y="48" font-family="system-ui, sans-serif" font-size="13" font-weight="500" fill="#94A3B8" text-anchor="end">Actors: Regular User &amp; Administrator</text>

  <!-- Standard UML Stick Figure: Regular User (Left) -->
  <g transform="translate(65, 230)">
    <!-- Head -->
    <circle cx="45" cy="45" r="22" fill="#EFF6FF" stroke="#1D4ED8" stroke-width="2.5"/>
    <!-- Body -->
    <line x1="45" y1="67" x2="45" y2="155" stroke="#1D4ED8" stroke-width="2.5"/>
    <!-- Arms -->
    <line x1="45" y1="95" x2="10" y2="135" stroke="#1D4ED8" stroke-width="2.5"/>
    <line x1="45" y1="95" x2="80" y2="135" stroke="#1D4ED8" stroke-width="2.5"/>
    <!-- Legs -->
    <line x1="45" y1="155" x2="15" y2="235" stroke="#1D4ED8" stroke-width="2.5"/>
    <line x1="45" y1="155" x2="75" y2="235" stroke="#1D4ED8" stroke-width="2.5"/>
    <text x="45" y="265" font-family="system-ui, sans-serif" font-size="14" font-weight="700" fill="#1E40AF" text-anchor="middle">Regular User</text>
    <text x="45" y="282" font-family="system-ui, sans-serif" font-size="11" fill="#475569" text-anchor="middle">(Mobile App Client)</text>
  </g>

  <!-- Standard UML Stick Figure: Administrator (Right) -->
  <g transform="translate(980, 230)">
    <!-- Head -->
    <circle cx="45" cy="45" r="22" fill="#FEF2F2" stroke="#DC2626" stroke-width="2.5"/>
    <!-- Body -->
    <line x1="45" y1="67" x2="45" y2="155" stroke="#DC2626" stroke-width="2.5"/>
    <!-- Arms -->
    <line x1="45" y1="95" x2="10" y2="135" stroke="#DC2626" stroke-width="2.5"/>
    <line x1="45" y1="95" x2="80" y2="135" stroke="#DC2626" stroke-width="2.5"/>
    <!-- Legs -->
    <line x1="45" y1="155" x2="15" y2="235" stroke="#DC2626" stroke-width="2.5"/>
    <line x1="45" y1="155" x2="75" y2="235" stroke="#DC2626" stroke-width="2.5"/>
    <text x="45" y="265" font-family="system-ui, sans-serif" font-size="14" font-weight="700" fill="#B91C1C" text-anchor="middle">Administrator</text>
    <text x="45" y="282" font-family="system-ui, sans-serif" font-size="11" fill="#475569" text-anchor="middle">(CMS &amp; Catalog Manager)</text>
  </g>

  <!-- System Boundary Box -->
  <rect x="200" y="85" width="740" height="605" rx="10" fill="#F8FAFC" stroke="#334155" stroke-width="2" stroke-dasharray="8 5"/>
  <rect x="200" y="85" width="310" height="28" rx="6" fill="#334155"/>
  <text x="215" y="104" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#FFFFFF">NutriView Application System Boundary</text>

  <!-- Use Cases: Regular User Domain -->
  <!-- UC-01: Auth & Login -->
  <g transform="translate(240, 135)">
    <ellipse cx="120" cy="24" rx="110" ry="24" fill="#EFF6FF" stroke="#2563EB" stroke-width="1.5"/>
    <text x="120" y="28" font-family="system-ui, sans-serif" font-size="11.5" font-weight="600" fill="#1E40AF" text-anchor="middle">UC-01: Registrasi &amp; Login Akun</text>
  </g>

  <!-- UC-02: Biometric (Extend UC-01) -->
  <g transform="translate(520, 120)">
    <ellipse cx="115" cy="22" rx="105" ry="22" fill="#F8FAFC" stroke="#64748B" stroke-width="1.3"/>
    <text x="115" y="26" font-family="system-ui, sans-serif" font-size="10.5" font-weight="500" fill="#334155" text-anchor="middle">UC-02: Otentikasi Biometrik</text>
  </g>

  <!-- UC-03: Setup Profile & Target -->
  <g transform="translate(240, 205)">
    <ellipse cx="120" cy="24" rx="110" ry="24" fill="#EFF6FF" stroke="#2563EB" stroke-width="1.5"/>
    <text x="120" y="24" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#1E40AF" text-anchor="middle">UC-03: Kelola Profil Fisik &amp;</text>
    <text x="120" y="38" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#1E40AF" text-anchor="middle">Target Gizi Harian</text>
  </g>

  <!-- UC-04: Hitung BMR Mifflin (Include UC-03) -->
  <g transform="translate(520, 185)">
    <ellipse cx="115" cy="22" rx="105" ry="22" fill="#F8FAFC" stroke="#64748B" stroke-width="1.3"/>
    <text x="115" y="26" font-family="system-ui, sans-serif" font-size="10.5" font-weight="500" fill="#334155" text-anchor="middle">UC-04: Hitung BMR/TDEE (Mifflin)</text>
  </g>

  <!-- UC-05: Pindai Makanan Kamera/Galeri -->
  <g transform="translate(240, 280)">
    <ellipse cx="120" cy="24" rx="110" ry="24" fill="#ECFDF5" stroke="#10B981" stroke-width="1.5"/>
    <text x="120" y="28" font-family="system-ui, sans-serif" font-size="11.5" font-weight="600" fill="#065F46" text-anchor="middle">UC-05: Pindai Makanan (Kamera/Galeri)</text>
  </g>

  <!-- UC-06: Deteksi YOLO26n On-Device (Include UC-05) -->
  <g transform="translate(520, 250)">
    <ellipse cx="115" cy="22" rx="105" ry="22" fill="#FEF3C7" stroke="#D97706" stroke-width="1.3"/>
    <text x="115" y="26" font-family="system-ui, sans-serif" font-size="10.5" font-weight="600" fill="#92400E" text-anchor="middle">UC-06: Deteksi YOLO26n Isolate</text>
  </g>

  <!-- UC-07: Pencarian Manual Katalog (Extend UC-05) -->
  <g transform="translate(520, 310)">
    <ellipse cx="115" cy="22" rx="105" ry="22" fill="#F8FAFC" stroke="#64748B" stroke-width="1.3"/>
    <text x="115" y="26" font-family="system-ui, sans-serif" font-size="10.5" font-weight="500" fill="#334155" text-anchor="middle">UC-07: Koreksi / Cari Manual</text>
  </g>

  <!-- UC-08: Konfirmasi Porsi & Catat Makan -->
  <g transform="translate(240, 370)">
    <ellipse cx="120" cy="24" rx="110" ry="24" fill="#EFF6FF" stroke="#2563EB" stroke-width="1.5"/>
    <text x="120" y="24" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#1E40AF" text-anchor="middle">UC-08: Konfirmasi Bobot Porsi</text>
    <text x="120" y="38" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#1E40AF" text-anchor="middle">&amp; Catat Makanan (Log Meal)</text>
  </g>

  <!-- UC-09: Hitung Nutrisi Porsi Proporsional (Include UC-08) -->
  <g transform="translate(520, 372)">
    <ellipse cx="115" cy="22" rx="105" ry="22" fill="#F8FAFC" stroke="#64748B" stroke-width="1.3"/>
    <text x="115" y="26" font-family="system-ui, sans-serif" font-size="10.5" font-weight="500" fill="#334155" text-anchor="middle">UC-09: Skala Nutrisi Proporsional</text>
  </g>

  <!-- UC-10: Pantau Dashboard & Macro Bento -->
  <g transform="translate(240, 455)">
    <ellipse cx="120" cy="24" rx="110" ry="24" fill="#EFF6FF" stroke="#2563EB" stroke-width="1.5"/>
    <text x="120" y="28" font-family="system-ui, sans-serif" font-size="11.5" font-weight="600" fill="#1E40AF" text-anchor="middle">UC-10: Pantau Dashboard &amp; Bento</text>
  </g>

  <!-- UC-11: Riwayat & Baca Artikel -->
  <g transform="translate(240, 525)">
    <ellipse cx="120" cy="24" rx="110" ry="24" fill="#EFF6FF" stroke="#2563EB" stroke-width="1.5"/>
    <text x="120" y="28" font-family="system-ui, sans-serif" font-size="11.5" font-weight="600" fill="#1E40AF" text-anchor="middle">UC-11: Telusuri Riwayat &amp; Artikel</text>
  </g>

  <!-- Use Cases: Administrator Domain (Right Side) -->
  <!-- UC-12: Kelola Katalog Master Pangan -->
  <g transform="translate(680, 445)">
    <ellipse cx="120" cy="24" rx="115" ry="24" fill="#FEF2F2" stroke="#DC2626" stroke-width="1.5"/>
    <text x="120" y="28" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#991B1B" text-anchor="middle">UC-12: Kelola Master Pangan TKPI</text>
  </g>

  <!-- UC-13: Verifikasi Atwater (Include UC-12) -->
  <g transform="translate(480, 447)">
    <ellipse cx="95" cy="22" rx="90" ry="22" fill="#F8FAFC" stroke="#64748B" stroke-width="1.3"/>
    <text x="95" y="26" font-family="system-ui, sans-serif" font-size="10" font-weight="500" fill="#334155" text-anchor="middle">UC-13: Validasi Atwater 4-4-9</text>
  </g>

  <!-- UC-14: Kelola Artikel CMS & Media Eksternal -->
  <g transform="translate(680, 510)">
    <ellipse cx="120" cy="24" rx="115" ry="24" fill="#FEF2F2" stroke="#DC2626" stroke-width="1.5"/>
    <text x="120" y="28" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#991B1B" text-anchor="middle">UC-14: Kelola CMS Artikel &amp; Media</text>
  </g>

  <!-- UC-15: Inspeksi Audit Log Tak Terubah -->
  <g transform="translate(680, 575)">
    <ellipse cx="120" cy="24" rx="115" ry="24" fill="#FEF2F2" stroke="#DC2626" stroke-width="1.5"/>
    <text x="120" y="28" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#991B1B" text-anchor="middle">UC-15: Inspeksi Log Audit Sistem</text>
  </g>

  <!-- UC-16: Manajemen Akun Pengguna -->
  <g transform="translate(680, 640)">
    <ellipse cx="120" cy="24" rx="115" ry="24" fill="#FEF2F2" stroke="#DC2626" stroke-width="1.5"/>
    <text x="120" y="28" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#991B1B" text-anchor="middle">UC-16: Kelola Status Aktivasi Akun</text>
  </g>

  <!-- UML Association Lines (Solid lines from Actor to Use Cases) -->
  <!-- User to UC-01, 03, 05, 08, 10, 11 -->
  <line x1="145" y1="325" x2="240" y2="159" stroke="#1E40AF" stroke-width="1.5"/>
  <line x1="145" y1="325" x2="240" y2="229" stroke="#1E40AF" stroke-width="1.5"/>
  <line x1="145" y1="325" x2="240" y2="304" stroke="#047857" stroke-width="1.5"/>
  <line x1="145" y1="325" x2="240" y2="394" stroke="#1E40AF" stroke-width="1.5"/>
  <line x1="145" y1="325" x2="240" y2="479" stroke="#1E40AF" stroke-width="1.5"/>
  <line x1="145" y1="325" x2="240" y2="549" stroke="#1E40AF" stroke-width="1.5"/>

  <!-- Admin to UC-12, 14, 15, 16 -->
  <line x1="990" y1="325" x2="915" y2="469" stroke="#DC2626" stroke-width="1.5"/>
  <line x1="990" y1="325" x2="915" y2="534" stroke="#DC2626" stroke-width="1.5"/>
  <line x1="990" y1="325" x2="915" y2="599" stroke="#DC2626" stroke-width="1.5"/>
  <line x1="990" y1="325" x2="915" y2="664" stroke="#DC2626" stroke-width="1.5"/>

  <!-- UML Relationship: <<extend>> UC-02 extends UC-01 -->
  <path fill="none" d="M 525 142 L 470 155" stroke="#475569" stroke-width="1.2" stroke-dasharray="4 3" marker-end="url(#arr-arrow)"/>
  <text x="495" y="142" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">&lt;&lt;extend&gt;&gt;</text>

  <!-- UML Relationship: <<include>> UC-03 includes UC-04 -->
  <path fill="none" d="M 470 220 L 525 207" stroke="#475569" stroke-width="1.2" stroke-dasharray="4 3" marker-end="url(#arr-arrow)"/>
  <text x="500" y="210" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">&lt;&lt;include&gt;&gt;</text>

  <!-- UML Relationship: <<include>> UC-05 includes UC-06 -->
  <path fill="none" d="M 470 295 L 525 272" stroke="#475569" stroke-width="1.2" stroke-dasharray="4 3" marker-end="url(#arr-arrow)"/>
  <text x="500" y="280" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">&lt;&lt;include&gt;&gt;</text>

  <!-- UML Relationship: <<extend>> UC-07 extends UC-05 -->
  <path fill="none" d="M 525 325 L 470 310" stroke="#475569" stroke-width="1.2" stroke-dasharray="4 3" marker-end="url(#arr-arrow)"/>
  <text x="500" y="325" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">&lt;&lt;extend&gt;&gt;</text>

  <!-- UML Relationship: <<include>> UC-08 includes UC-09 -->
  <path fill="none" d="M 470 394 L 520 394" stroke="#475569" stroke-width="1.2" stroke-dasharray="4 3" marker-end="url(#arr-arrow)"/>
  <text x="495" y="388" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">&lt;&lt;include&gt;&gt;</text>

  <!-- UML Relationship: <<include>> UC-12 includes UC-13 -->
  <path fill="none" d="M 685 469 L 665 469" stroke="#475569" stroke-width="1.2" stroke-dasharray="4 3" marker-end="url(#arr-arrow)"/>
  <text x="675" y="462" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">&lt;&lt;include&gt;&gt;</text>
</svg>"""
    svg_path = os.path.join(OUTPUT_DIR, "fig2_use_case_diagram.svg")
    png_path = os.path.join(OUTPUT_DIR, "fig2_use_case_diagram.png")
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(svg)
    render_svg_to_png(svg_path, png_path, w, h)


# ==========================================
# 4. Navigation Flowchart
# ==========================================
def generate_navigation_flow():
    w, h = 1050, 640
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <defs>
    <marker id="arr-nav" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#2563EB"/>
    </marker>
    <marker id="arr-gray" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#64748B"/>
    </marker>
    <filter id="shadow" x="-3%" y="-3%" width="106%" height="106%">
      <feDropShadow dx="2" dy="2" stdDeviation="2" flood-color="#0F172A" flood-opacity="0.08"/>
    </filter>
  </defs>

  <rect width="{w}" height="{h}" fill="#F8FAFC"/>
  <rect x="15" y="15" width="{w-30}" height="{h-30}" rx="10" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>

  <!-- Title Header -->
  <rect x="15" y="15" width="{w-30}" height="55" rx="10" fill="#0F172A"/>
  <rect x="15" y="55" width="{w-30}" height="15" fill="#0F172A"/>
  <text x="35" y="48" font-family="system-ui, sans-serif" font-size="18" font-weight="700" fill="#FFFFFF">NutriView — Application Screen Navigation &amp; Routing Flowchart</text>
  <text x="{w-35}" y="48" font-family="system-ui, sans-serif" font-size="13" font-weight="500" fill="#94A3B8" text-anchor="end">NeoBottomNav Shell &amp; Auth Gates</text>

  <!-- Left: Entry & Auth Gate -->
  <g transform="translate(35, 95)" filter="url(#shadow)">
    <!-- SplashScreen -->
    <rect x="0" y="0" width="160" height="55" rx="6" fill="#FFFBEB" stroke="#F59E0B" stroke-width="1.5"/>
    <text x="80" y="24" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#92400E" text-anchor="middle">SplashScreen</text>
    <text x="80" y="40" font-family="system-ui, sans-serif" font-size="9" fill="#B45309" text-anchor="middle">Bootstrap &amp; Session Check</text>

    <!-- Auth Decision Diamond -->
    <path d="M 80 85 L 140 125 L 80 165 L 20 125 Z" fill="#F1F5F9" stroke="#475569" stroke-width="1.5"/>
    <text x="80" y="122" font-family="system-ui, sans-serif" font-size="10" font-weight="600" fill="#0F172A" text-anchor="middle">Valid</text>
    <text x="80" y="134" font-family="system-ui, sans-serif" font-size="10" font-weight="600" fill="#0F172A" text-anchor="middle">Session?</text>

    <!-- LoginScreen -->
    <rect x="0" y="200" width="160" height="65" rx="6" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.5"/>
    <text x="80" y="222" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#1E40AF" text-anchor="middle">LoginScreen</text>
    <text x="80" y="238" font-family="system-ui, sans-serif" font-size="9" fill="#2563EB" text-anchor="middle">Email, Google, Biometric</text>
    <text x="80" y="252" font-family="system-ui, sans-serif" font-size="8.5" fill="#64748B" text-anchor="middle">Modal: Forgot Password</text>

    <!-- RegisterScreen -->
    <rect x="0" y="295" width="160" height="55" rx="6" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.5"/>
    <text x="80" y="318" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#1E40AF" text-anchor="middle">RegisterScreen</text>
    <text x="80" y="334" font-family="system-ui, sans-serif" font-size="9" fill="#2563EB" text-anchor="middle">Validation &amp; Auto-User Role</text>

    <!-- Admin Login / Guard -->
    <rect x="0" y="440" width="160" height="65" rx="6" fill="#FEF2F2" stroke="#EF4444" stroke-width="1.5"/>
    <text x="80" y="462" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#991B1B" text-anchor="middle">Admin Guard Route</text>
    <text x="80" y="478" font-family="system-ui, sans-serif" font-size="9" fill="#DC2626" text-anchor="middle">Role Verification ('admin')</text>
    <text x="80" y="492" font-family="system-ui, sans-serif" font-size="8.5" fill="#7F1D1D" text-anchor="middle">Redirect if Unauthorized</text>
  </g>

  <!-- Connector Lines on Left -->
  <line x1="115" y1="150" x2="115" y2="180" stroke="#64748B" stroke-width="1.5" marker-end="url(#arr-gray)"/>
  <line x1="115" y1="260" x2="115" y2="295" stroke="#64748B" stroke-width="1.5" stroke-dasharray="3 3"/>
  <line x1="115" y1="360" x2="115" y2="395" stroke="#2563EB" stroke-width="1.5"/>
  <text x="125" y="175" font-family="system-ui, sans-serif" font-size="9" fill="#B91C1C">No</text>

  <!-- Main Floating Shell (NeoBottomNav) -->
  <rect x="235" y="95" width="560" height="520" rx="8" fill="#F8FAFC" stroke="#10B981" stroke-width="2" filter="url(#shadow)"/>
  <rect x="235" y="95" width="560" height="34" rx="8" fill="#D1FAE5"/>
  <rect x="235" y="119" width="560" height="10" fill="#D1FAE5"/>
  <text x="250" y="118" font-family="system-ui, sans-serif" font-size="13" font-weight="700" fill="#065F46">MAIN NAVIGATION SHELL (NeoBottomNav — 5 Interconnected Tabs)</text>

  <!-- Connect from Auth Diamond to Shell -->
  <path fill="none" d="M 175 220 L 210 220 L 210 145 L 235 145" stroke="#2563EB" stroke-width="2" marker-end="url(#arr-nav)"/>
  <text x="185" y="135" font-family="system-ui, sans-serif" font-size="10" font-weight="600" fill="#16A34A">Yes (Auth OK)</text>

  <!-- 5 Shell Tabs Grid -->
  <!-- Tab 1: Dashboard -->
  <g transform="translate(255, 145)">
    <rect x="0" y="0" width="245" height="100" rx="6" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>
    <rect x="0" y="0" width="245" height="24" rx="6" fill="#EFF6FF"/>
    <text x="122" y="16" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#1E40AF" text-anchor="middle">Tab 1: DashboardScreen</text>
    <text x="12" y="38" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• DailyCalorieHeroCard (Dial Progress)</text>
    <text x="12" y="52" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• MacroBentoGrid (P, C, F Distribution)</text>
    <text x="12" y="66" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• RecentMealsList (Today's Intake)</text>
    <text x="12" y="80" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• Quick Calorie Deficit/Surplus Status</text>
  </g>

  <!-- Tab 2: Meal History -->
  <g transform="translate(530, 145)">
    <rect x="0" y="0" width="245" height="100" rx="6" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>
    <rect x="0" y="0" width="245" height="24" rx="6" fill="#EFF6FF"/>
    <text x="122" y="16" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#1E40AF" text-anchor="middle">Tab 2: MealHistoryScreen</text>
    <text x="12" y="38" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• Interactive DatePicker (yyyy-MM-dd)</text>
    <text x="12" y="52" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• Categorized Meal Group (B, L, D, S)</text>
    <text x="12" y="66" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• Tap Item ➔ MealDetailScreen</text>
    <text x="12" y="80" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• Delete Confirmation Dialog</text>
  </g>

  <!-- Tab 3: Scanner Core Pipeline (Center Floating Button) -->
  <g transform="translate(255, 260)">
    <rect x="0" y="0" width="520" height="185" rx="6" fill="#FFFBEB" stroke="#F59E0B" stroke-width="1.5"/>
    <rect x="0" y="0" width="520" height="26" rx="6" fill="#FEF3C7"/>
    <text x="260" y="18" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#92400E" text-anchor="middle">Tab 3 (Center Action): Computer Vision Food Logging Subflow</text>

    <!-- Sub-steps horizontal -->
    <rect x="15" y="38" width="110" height="65" rx="4" fill="#FFFFFF" stroke="#FBBF24" stroke-width="1.2"/>
    <text x="70" y="56" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#78350F" text-anchor="middle">ScannerScreen</text>
    <text x="70" y="72" font-family="system-ui, sans-serif" font-size="8.5" fill="#92400E" text-anchor="middle">Camera Viewfinder</text>
    <text x="70" y="86" font-family="system-ui, sans-serif" font-size="8.5" fill="#92400E" text-anchor="middle">Gallery Picker</text>

    <line x1="125" y1="70" x2="145" y2="70" stroke="#F59E0B" stroke-width="1.5" marker-end="url(#arr-nav)"/>

    <rect x="145" y="38" width="110" height="65" rx="4" fill="#FFFFFF" stroke="#FBBF24" stroke-width="1.2"/>
    <text x="200" y="56" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#78350F" text-anchor="middle">Worker Isolate</text>
    <text x="200" y="72" font-family="system-ui, sans-serif" font-size="8.5" fill="#92400E" text-anchor="middle">YOLO26n Inference</text>
    <text x="200" y="86" font-family="system-ui, sans-serif" font-size="8.5" fill="#92400E" text-anchor="middle">NMS Filtering</text>

    <line x1="255" y1="70" x2="275" y2="70" stroke="#F59E0B" stroke-width="1.5" marker-end="url(#arr-nav)"/>

    <rect x="275" y="38" width="115" height="65" rx="4" fill="#FFFFFF" stroke="#FBBF24" stroke-width="1.2"/>
    <text x="332" y="54" font-family="system-ui, sans-serif" font-size="9.5" font-weight="700" fill="#78350F" text-anchor="middle">DetectionConfirm</text>
    <text x="332" y="68" font-family="system-ui, sans-serif" font-size="8.5" fill="#92400E" text-anchor="middle">Bounding Box Review</text>
    <text x="332" y="82" font-family="system-ui, sans-serif" font-size="8.5" fill="#92400E" text-anchor="middle">FoodSearchModal</text>

    <line x1="390" y1="70" x2="405" y2="70" stroke="#F59E0B" stroke-width="1.5" marker-end="url(#arr-nav)"/>

    <rect x="405" y="38" width="100" height="65" rx="4" fill="#FFFFFF" stroke="#FBBF24" stroke-width="1.2"/>
    <text x="455" y="54" font-family="system-ui, sans-serif" font-size="9.5" font-weight="700" fill="#78350F" text-anchor="middle">PortionInput</text>
    <text x="455" y="68" font-family="system-ui, sans-serif" font-size="8.5" fill="#92400E" text-anchor="middle">Serving Grams</text>
    <text x="455" y="82" font-family="system-ui, sans-serif" font-size="8.5" fill="#92400E" text-anchor="middle">MealResultScreen</text>

    <rect x="15" y="118" width="490" height="52" rx="4" fill="#FEF3C7" stroke="#F59E0B" stroke-width="1"/>
    <text x="25" y="136" font-family="system-ui, sans-serif" font-size="9.5" font-weight="700" fill="#92400E">Graceful Correction &amp; Fallback Options:</text>
    <text x="25" y="152" font-family="system-ui, sans-serif" font-size="9" fill="#78350F">• Score &lt; 0.30 ➔ Low Confidence Warning • Manual Search ➔ 29 Indonesian Food Catalog / seed_foods.json</text>
    <text x="25" y="164" font-family="system-ui, sans-serif" font-size="9" fill="#78350F">• On Save ➔ Atomic write to users/{{uid}}/meals/{{id}} ➔ Instant Dashboard state recalculation</text>
  </g>

  <!-- Tab 4: Articles -->
  <g transform="translate(255, 460)">
    <rect x="0" y="0" width="245" height="140" rx="6" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>
    <rect x="0" y="0" width="245" height="24" rx="6" fill="#EFF6FF"/>
    <text x="122" y="16" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#1E40AF" text-anchor="middle">Tab 4: ArticleScreen</text>
    <text x="12" y="42" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• Nutrition Education Articles</text>
    <text x="12" y="58" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• Category Filter Chips</text>
    <text x="12" y="74" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• Instant Search Bar</text>
    <text x="12" y="90" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• Tap ➔ ArticleDetailScreen</text>
    <text x="12" y="106" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• Reading Time Calculator</text>
    <text x="12" y="122" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• Fallback Image Cache</text>
  </g>

  <!-- Tab 5: Profile -->
  <g transform="translate(530, 460)">
    <rect x="0" y="0" width="245" height="140" rx="6" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>
    <rect x="0" y="0" width="245" height="24" rx="6" fill="#EFF6FF"/>
    <text x="122" y="16" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#1E40AF" text-anchor="middle">Tab 5: ProfileScreen</text>
    <text x="12" y="42" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• BiodataScreen (Age, TB, BB, Goal)</text>
    <text x="12" y="58" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• Avatar Picker (Vector Presets)</text>
    <text x="12" y="74" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• AboutScreen (Creator &amp; Version)</text>
    <text x="12" y="90" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• Biometric Lock Toggle Switch</text>
    <text x="12" y="106" font-family="system-ui, sans-serif" font-size="9.5" fill="#334155">• Account Deletion &amp; Data Purge</text>
    <text x="12" y="122" font-family="system-ui, sans-serif" font-size="9.5" fill="#B91C1C">• Logout (Session Flush &amp; Cache Wipe)</text>
  </g>

  <!-- Right: Admin Dashboard Portal Boundary -->
  <g transform="translate(820, 95)" filter="url(#shadow)">
    <rect x="0" y="0" width="190" height="520" rx="8" fill="#F8FAFC" stroke="#DC2626" stroke-width="2"/>
    <rect x="0" y="0" width="190" height="34" rx="8" fill="#FEE2E2"/>
    <rect x="0" y="24" width="190" height="10" fill="#FEE2E2"/>
    <text x="95" y="22" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#991B1B" text-anchor="middle">Admin Dashboard Portal</text>

    <rect x="12" y="48" width="166" height="85" rx="4" fill="#FFFFFF" stroke="#FCA5A5" stroke-width="1.2"/>
    <text x="20" y="68" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#7F1D1D">Food Catalog Master:</text>
    <text x="20" y="84" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Create / Update Food</text>
    <text x="20" y="98" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Atwater Simulator</text>
    <text x="20" y="112" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• TKPI 2020 Sync</text>
    <text x="20" y="126" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Toggle Active Status</text>

    <rect x="12" y="145" width="166" height="85" rx="4" fill="#FFFFFF" stroke="#FCA5A5" stroke-width="1.2"/>
    <text x="20" y="165" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#7F1D1D">CMS Content Hub:</text>
    <text x="20" y="181" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Draft &amp; Publish Articles</text>
    <text x="20" y="195" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Category Taxonomies</text>
    <text x="20" y="209" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• External Image URLs</text>
    <text x="20" y="223" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Banner Announcements</text>

    <rect x="12" y="242" width="166" height="85" rx="4" fill="#FFFFFF" stroke="#FCA5A5" stroke-width="1.2"/>
    <text x="20" y="262" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#7F1D1D">Immutable Audit Logs:</text>
    <text x="20" y="278" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Read Admin Actions</text>
    <text x="20" y="292" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Timestamped Actors</text>
    <text x="20" y="306" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Update/Delete Denied</text>
    <text x="20" y="320" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Full Forensic History</text>

    <rect x="12" y="340" width="166" height="85" rx="4" fill="#FFFFFF" stroke="#FCA5A5" stroke-width="1.2"/>
    <text x="20" y="360" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#7F1D1D">User Governance:</text>
    <text x="20" y="376" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Inspect User List</text>
    <text x="20" y="390" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Activate / Deactivate</text>
    <text x="20" y="404" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Account Termination</text>
    <text x="20" y="418" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Anti-Escalation Shield</text>

    <rect x="12" y="438" width="166" height="70" rx="4" fill="#FEF2F2" stroke="#EF4444" stroke-width="1"/>
    <text x="20" y="458" font-family="system-ui, sans-serif" font-size="9.5" font-weight="700" fill="#7F1D1D">Responsive Admin UI:</text>
    <text x="20" y="474" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Drawer on Mobile Screen</text>
    <text x="20" y="488" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Fixed Sidebar (w &gt;= 900)</text>
    <text x="20" y="502" font-family="system-ui, sans-serif" font-size="8.5" fill="#991B1B">• Rule F NeoActionButton</text>
  </g>
</svg>"""
    svg_path = os.path.join(OUTPUT_DIR, "fig3_navigation_flow.svg")
    png_path = os.path.join(OUTPUT_DIR, "fig3_navigation_flow.png")
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(svg)
    render_svg_to_png(svg_path, png_path, w, h)


# ==========================================
# 5. Activity Diagram
# ==========================================
def generate_activity_diagram():
    w, h = 1100, 720
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <defs>
    <marker id="arr-act" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#1E293B"/>
    </marker>
    <filter id="shadow" x="-3%" y="-3%" width="106%" height="106%">
      <feDropShadow dx="2" dy="2" stdDeviation="2" flood-color="#0F172A" flood-opacity="0.08"/>
    </filter>
  </defs>

  <rect width="{w}" height="{h}" fill="#F8FAFC"/>
  <rect x="15" y="15" width="{w-30}" height="{h-30}" rx="10" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>

  <!-- Title Header -->
  <rect x="15" y="15" width="{w-30}" height="55" rx="10" fill="#0F172A"/>
  <rect x="15" y="55" width="{w-30}" height="15" fill="#0F172A"/>
  <text x="35" y="48" font-family="system-ui, sans-serif" font-size="18" font-weight="700" fill="#FFFFFF">NutriView — UML Activity Diagram with Swimlanes</text>
  <text x="{w-35}" y="48" font-family="system-ui, sans-serif" font-size="13" font-weight="500" fill="#94A3B8" text-anchor="end">On-Device AI Detection &amp; Meal Logging Flow</text>

  <!-- 4 Swimlanes -->
  <!-- Lane 1: Pengguna (User) -->
  <rect x="35" y="85" width="240" height="605" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>
  <rect x="35" y="85" width="240" height="36" fill="#F1F5F9" stroke="#CBD5E1" stroke-width="1.5"/>
  <text x="155" y="108" font-family="system-ui, sans-serif" font-size="13" font-weight="700" fill="#0F172A" text-anchor="middle">Pengguna (Regular User)</text>

  <!-- Lane 2: Flutter UI & State Management -->
  <rect x="275" y="85" width="265" height="605" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1.5"/>
  <rect x="275" y="85" width="265" height="36" fill="#EFF6FF" stroke="#CBD5E1" stroke-width="1.5"/>
  <text x="407" y="108" font-family="system-ui, sans-serif" font-size="13" font-weight="700" fill="#1E40AF" text-anchor="middle">Flutter UI &amp; Providers</text>

  <!-- Lane 3: Worker Isolate & YOLO26n Engine -->
  <rect x="540" y="85" width="265" height="605" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>
  <rect x="540" y="85" width="265" height="36" fill="#FEF3C7" stroke="#CBD5E1" stroke-width="1.5"/>
  <text x="672" y="108" font-family="system-ui, sans-serif" font-size="13" font-weight="700" fill="#92400E" text-anchor="middle">Worker Isolate (YOLO26n)</text>

  <!-- Lane 4: Cloud Firestore & Local Cache -->
  <rect x="805" y="85" width="255" height="605" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1.5"/>
  <rect x="805" y="85" width="255" height="36" fill="#ECFDF5" stroke="#CBD5E1" stroke-width="1.5"/>
  <text x="932" y="108" font-family="system-ui, sans-serif" font-size="13" font-weight="700" fill="#065F46" text-anchor="middle">Firestore &amp; Bounded Cache</text>

  <!-- Activity Nodes -->
  <!-- Initial Node in Lane 1 -->
  <circle cx="155" cy="145" r="14" fill="#0F172A"/>

  <!-- Action: Buka Kamera / Pilih Galeri -->
  <rect x="55" y="180" width="200" height="42" rx="15" fill="#EFF6FF" stroke="#2563EB" stroke-width="1.3"/>
  <text x="155" y="206" font-family="system-ui, sans-serif" font-size="11" font-weight="600" fill="#1E40AF" text-anchor="middle">Potret / Pilih Foto Makanan</text>

  <line x1="155" y1="159" x2="155" y2="180" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>

  <!-- Transition to Lane 2: Tangkap Bytes Citra -->
  <rect x="295" y="180" width="225" height="42" rx="15" fill="#EFF6FF" stroke="#2563EB" stroke-width="1.3"/>
  <text x="407" y="198" font-family="system-ui, sans-serif" font-size="10.5" font-weight="600" fill="#1E40AF" text-anchor="middle">Tangkap Image Bytes</text>
  <text x="407" y="212" font-family="system-ui, sans-serif" font-size="9" fill="#3B82F6" text-anchor="middle">&amp; Delegasikan ke Background Isolate</text>

  <line x1="255" y1="201" x2="295" y2="201" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>

  <!-- Transition to Lane 3: Preprocessing & Inference -->
  <rect x="560" y="180" width="225" height="42" rx="15" fill="#FFFBEB" stroke="#D97706" stroke-width="1.3"/>
  <text x="672" y="198" font-family="system-ui, sans-serif" font-size="10.5" font-weight="600" fill="#92400E" text-anchor="middle">Pra-pemrosesan Citra</text>
  <text x="672" y="212" font-family="system-ui, sans-serif" font-size="9" fill="#B45309" text-anchor="middle">bakeOrientation, Resize 640, Norm [0,1]</text>

  <line x1="520" y1="201" x2="560" y2="201" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>

  <rect x="560" y="245" width="225" height="42" rx="15" fill="#FFFBEB" stroke="#D97706" stroke-width="1.3"/>
  <text x="672" y="263" font-family="system-ui, sans-serif" font-size="10.5" font-weight="600" fill="#92400E" text-anchor="middle">Eksekusi Model TFLite</text>
  <text x="672" y="277" font-family="system-ui, sans-serif" font-size="9" fill="#B45309" text-anchor="middle">Interpreter.run() ➔ Tensor [1,33,8400]</text>

  <line x1="672" y1="222" x2="672" y2="245" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>

  <rect x="560" y="310" width="225" height="42" rx="15" fill="#FFFBEB" stroke="#D97706" stroke-width="1.3"/>
  <text x="672" y="328" font-family="system-ui, sans-serif" font-size="10.5" font-weight="600" fill="#92400E" text-anchor="middle">NMS Filtering (IoU 0.45)</text>
  <text x="672" y="342" font-family="system-ui, sans-serif" font-size="9" fill="#B45309" text-anchor="middle">Ambil Bounding Box &amp; Best Class</text>

  <line x1="672" y1="287" x2="672" y2="310" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>

  <!-- Return to Lane 2: Pemetaan Katalog & Tampilkan Hasil -->
  <rect x="295" y="310" width="225" height="42" rx="15" fill="#EFF6FF" stroke="#2563EB" stroke-width="1.3"/>
  <text x="407" y="328" font-family="system-ui, sans-serif" font-size="10.5" font-weight="600" fill="#1E40AF" text-anchor="middle">Cocokkan Katalog Makanan</text>
  <text x="407" y="342" font-family="system-ui, sans-serif" font-size="9" fill="#3B82F6" text-anchor="middle">Mapping Nama &amp; Nilai Gizi Dasar</text>

  <line x1="560" y1="331" x2="520" y2="331" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>

  <!-- Decision 1: Keyakinan Deteksi >= 0.30? -->
  <path d="M 407 375 L 442 395 L 407 415 L 372 395 Z" fill="#FEF3C7" stroke="#D97706" stroke-width="1.3"/>
  <text x="407" y="398" font-family="system-ui, sans-serif" font-size="8.5" font-weight="600" fill="#92400E" text-anchor="middle">Conf &gt;= 0.30?</text>

  <line x1="407" y1="352" x2="407" y2="375" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>

  <!-- Decision Branch Yes/No in Lane 2 -->
  <line x1="372" y1="395" x2="310" y2="395" stroke="#1E293B" stroke-width="1.5"/>
  <line x1="310" y1="395" x2="310" y2="435" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>
  <text x="330" y="388" font-family="system-ui, sans-serif" font-size="8.5" fill="#B91C1C">Tidak (&lt; 0.30)</text>

  <line x1="407" y1="415" x2="407" y2="435" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>
  <text x="415" y="428" font-family="system-ui, sans-serif" font-size="8.5" fill="#047857">Ya</text>

  <rect x="285" y="435" width="245" height="42" rx="15" fill="#EFF6FF" stroke="#2563EB" stroke-width="1.3"/>
  <text x="407" y="453" font-family="system-ui, sans-serif" font-size="10.5" font-weight="600" fill="#1E40AF" text-anchor="middle">Tampilkan Layar Konfirmasi</text>
  <text x="407" y="467" font-family="system-ui, sans-serif" font-size="9" fill="#3B82F6" text-anchor="middle">Box, Label &amp; Warning Low Confidence</text>

  <!-- Transition to Lane 1: Pengguna Review / Koreksi -->
  <rect x="55" y="435" width="200" height="42" rx="15" fill="#EFF6FF" stroke="#2563EB" stroke-width="1.3"/>
  <text x="155" y="453" font-family="system-ui, sans-serif" font-size="10.5" font-weight="600" fill="#1E40AF" text-anchor="middle">Verifikasi / Cari Manual</text>
  <text x="155" y="467" font-family="system-ui, sans-serif" font-size="9" fill="#3B82F6" text-anchor="middle">&amp; Input Bobot Porsi (Gram)</text>

  <line x1="285" y1="456" x2="255" y2="456" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>

  <!-- User Submits Meal -->
  <line x1="155" y1="477" x2="155" y2="520" stroke="#1E293B" stroke-width="1.5"/>
  <line x1="155" y1="520" x2="295" y2="520" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>

  <!-- Lane 2: Hitung Skala Gizi Porsi -->
  <rect x="295" y="500" width="225" height="42" rx="15" fill="#EFF6FF" stroke="#2563EB" stroke-width="1.3"/>
  <text x="407" y="518" font-family="system-ui, sans-serif" font-size="10.5" font-weight="600" fill="#1E40AF" text-anchor="middle">Hitung Gizi Sajian Proporsional</text>
  <text x="407" y="532" font-family="system-ui, sans-serif" font-size="9" fill="#3B82F6" text-anchor="middle">Kalori, P, C, F berdasarkan gramatur</text>

  <!-- Transition to Lane 4: Persistensi Data -->
  <line x1="520" y1="521" x2="820" y2="521" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>

  <!-- Decision 2 in Lane 4: Online vs Offline? -->
  <path d="M 855 500 L 890 521 L 855 542 L 820 521 Z" fill="#ECFDF5" stroke="#10B981" stroke-width="1.3"/>
  <text x="855" y="524" font-family="system-ui, sans-serif" font-size="8.5" font-weight="600" fill="#065F46" text-anchor="middle">Online?</text>

  <!-- Branch Offline -->
  <line x1="855" y1="542" x2="855" y2="575" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>
  <text x="860" y="558" font-family="system-ui, sans-serif" font-size="8" fill="#B91C1C">Offline</text>

  <rect x="815" y="575" width="230" height="42" rx="15" fill="#F8FAFC" stroke="#64748B" stroke-width="1.3"/>
  <text x="930" y="593" font-family="system-ui, sans-serif" font-size="10" font-weight="600" fill="#334155" text-anchor="middle">Simpan ke 100MB SQLite Cache</text>
  <text x="930" y="607" font-family="system-ui, sans-serif" font-size="8.5" fill="#475569" text-anchor="middle">Antrekan Mutasi Menunggu Jaringan</text>

  <!-- Branch Online -->
  <line x1="890" y1="521" x2="940" y2="521" stroke="#1E293B" stroke-width="1.5"/>
  <line x1="940" y1="521" x2="940" y2="545" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>
  <text x="945" y="515" font-family="system-ui, sans-serif" font-size="8" fill="#047857">Online</text>

  <rect x="825" y="545" width="220" height="26" rx="13" fill="#ECFDF5" stroke="#10B981" stroke-width="1.3"/>
  <text x="935" y="561" font-family="system-ui, sans-serif" font-size="9.5" font-weight="600" fill="#065F46" text-anchor="middle">Sync users/{{uid}}/meals/{{id}} Cloud</text>

  <!-- Join Node / Merge -->
  <rect x="915" y="635" width="40" height="6" rx="2" fill="#0F172A"/>

  <line x1="940" y1="571" x2="940" y2="635" stroke="#1E293B" stroke-width="1.5"/>
  <line x1="930" y1="617" x2="930" y2="635" stroke="#1E293B" stroke-width="1.5"/>

  <!-- Return update to UI & Dashboard -->
  <line x1="915" y1="638" x2="407" y2="638" stroke="#1E293B" stroke-width="1.5"/>
  <line x1="407" y1="638" x2="407" y2="615" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>

  <rect x="295" y="575" width="225" height="40" rx="15" fill="#EFF6FF" stroke="#2563EB" stroke-width="1.3"/>
  <text x="407" y="593" font-family="system-ui, sans-serif" font-size="10.5" font-weight="600" fill="#1E40AF" text-anchor="middle">Perbarui State Dashboard</text>
  <text x="407" y="607" font-family="system-ui, sans-serif" font-size="9" fill="#3B82F6" text-anchor="middle">Recalculate Dial &amp; Macro Bento</text>

  <!-- Final Node in Lane 1 -->
  <line x1="295" y1="595" x2="175" y2="595" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-act)"/>
  
  <circle cx="155" cy="595" r="14" fill="none" stroke="#0F172A" stroke-width="2"/>
  <circle cx="155" cy="595" r="8" fill="#0F172A"/>
  <text x="155" y="625" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#0F172A" text-anchor="middle">Selesai</text>
</svg>"""
    svg_path = os.path.join(OUTPUT_DIR, "fig3b_activity_diagram.svg")
    png_path = os.path.join(OUTPUT_DIR, "fig3b_activity_diagram.png")
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(svg)
    render_svg_to_png(svg_path, png_path, w, h)


# ==========================================
# 6. Database ERD & Document Schema
# ==========================================
def generate_database_erd():
    w, h = 1150, 780
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <defs>
    <marker id="arr-sub" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#1E293B"/>
    </marker>
    <filter id="shadow" x="-3%" y="-3%" width="106%" height="106%">
      <feDropShadow dx="2" dy="2" stdDeviation="2" flood-color="#0F172A" flood-opacity="0.08"/>
    </filter>
  </defs>

  <rect width="{w}" height="{h}" fill="#F8FAFC"/>
  <rect x="15" y="15" width="{w-30}" height="{h-30}" rx="10" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>

  <!-- Title Header -->
  <rect x="15" y="15" width="{w-30}" height="55" rx="10" fill="#0F172A"/>
  <rect x="15" y="55" width="{w-30}" height="15" fill="#0F172A"/>
  <text x="35" y="48" font-family="system-ui, sans-serif" font-size="18" font-weight="700" fill="#FFFFFF">NutriView — Cloud Firestore Document Schema Model (ERD)</text>
  <text x="{w-35}" y="48" font-family="system-ui, sans-serif" font-size="13" font-weight="500" fill="#94A3B8" text-anchor="end">NoSQL Collections, Subcollections &amp; Embedded Maps</text>

  <!-- Collection 1: users/{{userId}} -->
  <g transform="translate(45, 95)" filter="url(#shadow)">
    <rect x="0" y="0" width="320" height="365" rx="6" fill="#FFFFFF" stroke="#2563EB" stroke-width="2"/>
    <rect x="0" y="0" width="320" height="32" rx="6" fill="#EFF6FF"/>
    <rect x="0" y="22" width="320" height="10" fill="#EFF6FF"/>
    <text x="15" y="22" font-family="system-ui, sans-serif" font-size="12.5" font-weight="700" fill="#1E40AF">users/{{userId}} (Top-Level Collection)</text>
    <line x1="0" y1="32" x2="320" y2="32" stroke="#2563EB" stroke-width="1.5"/>

    <g transform="translate(15, 52)" font-family="monospace" font-size="10.5">
      <text y="0" font-weight="bold" fill="#0F172A">+ uid: string &lt;PK / Auth UID&gt;</text>
      <text y="18" fill="#334155">+ email: string</text>
      <text y="36" fill="#334155">+ full_name: string</text>
      <text y="54" font-weight="bold" fill="#B91C1C">+ role: 'user' | 'admin' &lt;Strict 2-Role&gt;</text>
      <text y="72" fill="#334155">+ is_active: boolean</text>
      <text y="90" fill="#334155">+ avatar_preset: string</text>
      <text y="108" fill="#334155">+ created_at: timestamp</text>
      <text y="126" fill="#334155">+ updated_at: timestamp</text>

      <line x1="0" y1="138" x2="290" y2="138" stroke="#E2E8F0" stroke-width="1"/>
      <text y="154" font-weight="bold" fill="#0369A1">+ profile: map</text>
      <text y="170" fill="#475569">    age: int, gender: string ('male'|'female')</text>
      <text y="186" fill="#475569">    height_cm: double, weight_kg: double</text>
      <text y="202" fill="#475569">    activity_level: string (1.2 - 1.9)</text>
      <text y="218" fill="#475569">    goal: string ('lose' | 'maintain' | 'gain')</text>

      <line x1="0" y1="230" x2="290" y2="230" stroke="#E2E8F0" stroke-width="1"/>
      <text y="246" font-weight="bold" fill="#047857">+ daily_target: map (Mifflin-St Jeor)</text>
      <text y="262" fill="#475569">    calories_kcal: int (min 1200/1500)</text>
      <text y="278" fill="#475569">    protein_g: double, carbs_g: double</text>
      <text y="294" fill="#475569">    fat_g: double, bmr_kcal: double</text>
    </g>
  </g>

  <!-- Subcollection 2: users/{{userId}}/meals/{{mealId}} -->
  <g transform="translate(435, 95)" filter="url(#shadow)">
    <rect x="0" y="0" width="340" height="340" rx="6" fill="#FFFFFF" stroke="#10B981" stroke-width="2"/>
    <rect x="0" y="0" width="340" height="32" rx="6" fill="#ECFDF5"/>
    <rect x="0" y="22" width="340" height="10" fill="#ECFDF5"/>
    <text x="15" y="22" font-family="system-ui, sans-serif" font-size="12.5" font-weight="700" fill="#065F46">users/{{userId}}/meals/{{mealId}} (Subcollection)</text>
    <line x1="0" y1="32" x2="340" y2="32" stroke="#10B981" stroke-width="1.5"/>

    <g transform="translate(15, 52)" font-family="monospace" font-size="10.5">
      <text y="0" font-weight="bold" fill="#0F172A">+ id: string / int &lt;PK / timestamp&gt;</text>
      <text y="18" fill="#334155">+ meal_type: 'breakfast'|'lunch'|'dinner'|'snack'</text>
      <text y="36" font-weight="bold" fill="#0369A1">+ consumed_date: string ('yyyy-MM-dd') &lt;Indexed&gt;</text>
      <text y="54" fill="#334155">+ consumed_at: timestamp</text>
      <text y="72" fill="#334155">+ created_at: timestamp</text>

      <line x1="0" y1="84" x2="310" y2="84" stroke="#E2E8F0" stroke-width="1"/>
      <text y="102" font-weight="bold" fill="#047857">+ totals: map (Accumulated Gizi)</text>
      <text y="118" fill="#475569">    calories: double, protein: double</text>
      <text y="134" fill="#475569">    carbs: double, fat: double</text>

      <line x1="0" y1="148" x2="310" y2="148" stroke="#E2E8F0" stroke-width="1"/>
      <text y="166" font-weight="bold" fill="#D97706">+ items: array&lt;map&gt; (Sajian Terkonsumsi)</text>
      <text y="184" fill="#475569">    food_id: int &lt;ref: foods.id&gt;</text>
      <text y="200" fill="#475569">    food_name: string</text>
      <text y="216" fill="#475569">    portion_grams: double (e.g. 150.0)</text>
      <text y="232" fill="#475569">    calories_kcal: double (scaled)</text>
      <text y="248" fill="#475569">    protein_g: double, carbs_g: double</text>
      <text y="264" fill="#475569">    fat_g: double</text>
      <text y="280" fill="#475569">    confidence: double (YOLO26n score)</text>
    </g>
  </g>

  <!-- Collection 3: foods/{{foodId}} -->
  <g transform="translate(45, 465)" filter="url(#shadow)">
    <rect x="0" y="0" width="320" height="270" rx="6" fill="#FFFFFF" stroke="#F59E0B" stroke-width="2"/>
    <rect x="0" y="0" width="320" height="32" rx="6" fill="#FEF3C7"/>
    <rect x="0" y="22" width="320" height="10" fill="#FEF3C7"/>
    <text x="15" y="22" font-family="system-ui, sans-serif" font-size="12.5" font-weight="700" fill="#92400E">foods/{{foodId}} (Master Catalog)</text>
    <line x1="0" y1="32" x2="320" y2="32" stroke="#F59E0B" stroke-width="1.5"/>

    <g transform="translate(15, 52)" font-family="monospace" font-size="10.5">
      <text y="0" font-weight="bold" fill="#0F172A">+ id: int &lt;PK / Unique Number&gt;</text>
      <text y="18" fill="#334155">+ name: string (e.g. 'Ayam Goreng')</text>
      <text y="36" font-weight="bold" fill="#0369A1">+ yolo_class: string (Model Class Label)</text>
      <text y="54" fill="#334155">+ is_active: boolean</text>
      <text y="72" fill="#334155">+ calories_kcal_per_100g: double</text>
      <text y="90" fill="#334155">+ protein_g_per_100g: double</text>
      <text y="108" fill="#334155">+ carbs_g_per_100g: double</text>
      <text y="126" fill="#334155">+ fat_g_per_100g: double</text>
      <text y="144" fill="#334155">+ source: 'TKPI 2020'</text>
      <text y="162" fill="#475569">+ created_at: timestamp</text>
      <text y="180" fill="#475569">+ updated_at: timestamp</text>
      <text y="202" font-size="9" font-style="italic" fill="#78350F">Validated via Atwater: 4P+4C+9F &lt;= 30% dev</text>
    </g>
  </g>

  <!-- Collection 4: cms_articles/{{articleId}} -->
  <g transform="translate(435, 465)" filter="url(#shadow)">
    <rect x="0" y="0" width="340" height="270" rx="6" fill="#FFFFFF" stroke="#8B5CF6" stroke-width="2"/>
    <rect x="0" y="0" width="340" height="32" rx="6" fill="#F5F3FF"/>
    <rect x="0" y="22" width="340" height="10" fill="#F5F3FF"/>
    <text x="15" y="22" font-family="system-ui, sans-serif" font-size="12.5" font-weight="700" fill="#6D28D9">cms_articles/{{articleId}} (Education)</text>
    <line x1="0" y1="32" x2="340" y2="32" stroke="#8B5CF6" stroke-width="1.5"/>

    <g transform="translate(15, 52)" font-family="monospace" font-size="10.5">
      <text y="0" font-weight="bold" fill="#0F172A">+ id: string &lt;PK / Document ID&gt;</text>
      <text y="18" fill="#334155">+ title: string</text>
      <text y="36" fill="#334155">+ slug: string &lt;Unique Slug&gt;</text>
      <text y="54" font-weight="bold" fill="#0369A1">+ status: 'published' | 'draft' &lt;Index&gt;</text>
      <text y="72" fill="#334155">+ cover_image_url: string (HTTPS URL)</text>
      <text y="90" fill="#334155">+ author_name: string</text>
      <text y="108" fill="#334155">+ category: string</text>
      <text y="126" fill="#334155">+ excerpt: string</text>
      <text y="144" fill="#334155">+ content: string (Markdown / HTML)</text>
      <text y="162" fill="#334155">+ read_time_minutes: int</text>
      <text y="180" font-weight="bold" fill="#0369A1">+ created_at: timestamp &lt;Indexed DESC&gt;</text>
    </g>
  </g>

  <!-- Right Side Column: Supporting CMS & Governance Collections -->
  <g transform="translate(825, 95)" filter="url(#shadow)">
    <!-- cms_audit_logs/{{logId}} -->
    <rect x="0" y="0" width="280" height="185" rx="6" fill="#FFFFFF" stroke="#DC2626" stroke-width="2"/>
    <rect x="0" y="0" width="280" height="30" rx="6" fill="#FEE2E2"/>
    <rect x="0" y="20" width="280" height="10" fill="#FEE2E2"/>
    <text x="12" y="20" font-family="system-ui, sans-serif" font-size="11.5" font-weight="700" fill="#991B1B">cms_audit_logs/{{logId}} (Immutable)</text>
    <line x1="0" y1="30" x2="280" y2="30" stroke="#DC2626" stroke-width="1.5"/>

    <g transform="translate(12, 48)" font-family="monospace" font-size="10">
      <text y="0" font-weight="bold" fill="#0F172A">+ id: string &lt;PK&gt;</text>
      <text y="16" fill="#334155">+ performed_by: string &lt;Auth UID&gt;</text>
      <text y="32" fill="#334155">+ action: string (e.g. 'CREATE_FOOD')</text>
      <text y="48" fill="#334155">+ target_collection: string</text>
      <text y="64" fill="#334155">+ timestamp: timestamp</text>
      <text y="80" fill="#334155">+ details: map&lt;string, dynamic&gt;</text>
      <text y="105" font-weight="bold" fill="#B91C1C">Security: update/delete = false</text>
      <text y="120" font-size="8.5" fill="#7F1D1D">Append-only audit trail for compliance</text>
    </g>

    <!-- cms_categories & cms_announcements -->
    <g transform="translate(0, 205)">
      <rect x="0" y="0" width="280" height="135" rx="6" fill="#FFFFFF" stroke="#64748B" stroke-width="1.5"/>
      <rect x="0" y="0" width="280" height="28" rx="6" fill="#F1F5F9"/>
      <text x="12" y="19" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#334155">cms_categories &amp; announcements</text>
      <line x1="0" y1="28" x2="280" y2="28" stroke="#64748B" stroke-width="1.2"/>

      <g transform="translate(12, 44)" font-family="monospace" font-size="9.5">
        <text y="0" font-weight="bold" fill="#0F172A">cms_categories/{{id}}</text>
        <text y="14" fill="#475569">+ id: string, name: string, slug: string</text>
        <line x1="0" y1="24" x2="255" y2="24" stroke="#E2E8F0" stroke-width="1"/>
        <text y="40" font-weight="bold" fill="#0F172A">cms_announcements/{{id}}</text>
        <text y="54" fill="#475569">+ id: string, title: string, message: string</text>
        <text y="68" fill="#475569">+ is_active: boolean, created_at: ts</text>
      </g>
    </g>

    <!-- cms_media/{{mediaId}} -->
    <g transform="translate(0, 360)">
      <rect x="0" y="0" width="280" height="150" rx="6" fill="#FFFFFF" stroke="#64748B" stroke-width="1.5"/>
      <rect x="0" y="0" width="280" height="28" rx="6" fill="#F1F5F9"/>
      <text x="12" y="19" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#334155">cms_media/{{mediaId}} (External URLs)</text>
      <line x1="0" y1="28" x2="280" y2="28" stroke="#64748B" stroke-width="1.2"/>

      <g transform="translate(12, 44)" font-family="monospace" font-size="9.5">
        <text y="0" font-weight="bold" fill="#0F172A">+ id: string &lt;PK&gt;</text>
        <text y="16" fill="#475569">+ url: string (HTTPS Web Image)</text>
        <text y="32" fill="#475569">+ file_name: string, uploaded_by: string</text>
        <text y="48" fill="#475569">+ created_at: timestamp</text>
        <text y="70" font-weight="bold" fill="#047857">Architectural Decision Record:</text>
        <text y="84" font-size="8.5" fill="#15803D">Eliminates Firebase Cloud Storage</text>
        <text y="96" font-size="8.5" fill="#15803D">Maintains $0 Spark Plan Boundary</text>
      </g>
    </g>
  </g>

  <!-- Relationship Connectors -->
  <!-- users to meals (Physical 1 : N Subcollection) -->
  <path fill="none" d="M 365 240 L 435 240" stroke="#0F172A" stroke-width="2.5" marker-end="url(#arr-sub)"/>
  <rect x="375" y="215" width="50" height="20" rx="3" fill="#0F172A"/>
  <text x="400" y="229" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#FFFFFF" text-anchor="middle">1 : N</text>
  <text x="400" y="254" font-family="system-ui, sans-serif" font-size="8.5" font-weight="600" fill="#047857" text-anchor="middle">Subcollection</text>

  <!-- foods to meals.items[] (Conceptual Reference) -->
  <path fill="none" d="M 365 580 L 400 580 L 400 380 L 435 380" stroke="#D97706" stroke-width="2" stroke-dasharray="6 3" marker-end="url(#arr-sub)"/>
  <rect x="370" y="470" width="60" height="22" rx="3" fill="#FFFBEB" stroke="#D97706" stroke-width="1"/>
  <text x="400" y="485" font-family="system-ui, sans-serif" font-size="8.5" font-weight="600" fill="#92400E" text-anchor="middle">referenced</text>

  <!-- users to cms_audit_logs (Conceptual Reference by UID) -->
  <path fill="none" d="M 205 95 L 205 78 L 965 78 L 965 95" stroke="#DC2626" stroke-width="1.5" stroke-dasharray="4 3" marker-end="url(#arr-sub)"/>
  <rect x="545" y="68" width="85" height="20" rx="3" fill="#FEE2E2" stroke="#DC2626" stroke-width="1"/>
  <text x="587" y="82" font-family="system-ui, sans-serif" font-size="8.5" font-weight="600" fill="#991B1B" text-anchor="middle">performed_by</text>
</svg>"""
    svg_path = os.path.join(OUTPUT_DIR, "fig5_database_erd.svg")
    png_path = os.path.join(OUTPUT_DIR, "fig5_database_erd.png")
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(svg)
    render_svg_to_png(svg_path, png_path, w, h)


# ==========================================
# 7. Authentication & Token Flow Topology
# ==========================================
def generate_token_flow():
    w, h = 1050, 580
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <defs>
    <marker id="arr-flow" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#2563EB"/>
    </marker>
    <filter id="shadow" x="-3%" y="-3%" width="106%" height="106%">
      <feDropShadow dx="2" dy="2" stdDeviation="2" flood-color="#0F172A" flood-opacity="0.08"/>
    </filter>
  </defs>

  <rect width="{w}" height="{h}" fill="#F8FAFC"/>
  <rect x="15" y="15" width="{w-30}" height="{h-30}" rx="10" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>

  <!-- Title Header -->
  <rect x="15" y="15" width="{w-30}" height="55" rx="10" fill="#0F172A"/>
  <rect x="15" y="55" width="{w-30}" height="15" fill="#0F172A"/>
  <text x="35" y="48" font-family="system-ui, sans-serif" font-size="18" font-weight="700" fill="#FFFFFF">NutriView — Authentication Token &amp; Secure Session Flow</text>
  <text x="{w-35}" y="48" font-family="system-ui, sans-serif" font-size="13" font-weight="500" fill="#94A3B8" text-anchor="end">Hardware KeyStore, Biometrics &amp; RBAC Verification</text>

  <!-- Step 1: User Sign In -->
  <g transform="translate(45, 110)" filter="url(#shadow)">
    <rect x="0" y="0" width="200" height="420" rx="6" fill="#FFFFFF" stroke="#3B82F6" stroke-width="1.5"/>
    <rect x="0" y="0" width="200" height="34" rx="6" fill="#EFF6FF"/>
    <text x="100" y="22" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#1E40AF" text-anchor="middle">1. Client Auth Gate</text>

    <g transform="translate(15, 50)" font-family="system-ui, sans-serif" font-size="10">
      <rect x="0" y="0" width="170" height="60" rx="4" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1"/>
      <text x="10" y="20" font-weight="700" fill="#0F172A">Credentials Input:</text>
      <text x="10" y="36" fill="#475569">• Email &amp; Password</text>
      <text x="10" y="50" fill="#475569">• Google OAuth 2.0</text>

      <rect x="0" y="75" width="170" height="60" rx="4" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1"/>
      <text x="10" y="95" font-weight="700" fill="#0F172A">Biometric Shortcut:</text>
      <text x="10" y="111" fill="#475569">• Fingerprint / FaceID</text>
      <text x="10" y="125" fill="#475569">• local_auth v3.0.2</text>

      <rect x="0" y="150" width="170" height="90" rx="4" fill="#FEF3C7" stroke="#F59E0B" stroke-width="1"/>
      <text x="10" y="170" font-weight="700" fill="#92400E">State Reaction:</text>
      <text x="10" y="186" fill="#78350F">• AuthProvider listens to</text>
      <text x="10" y="200" fill="#78350F">  authStateChanges()</text>
      <text x="10" y="214" fill="#78350F">• Auto-login if local</text>
      <text x="10" y="228" fill="#78350F">  session is valid</text>
    </g>
  </g>

  <!-- Step 2: Firebase Identity Platform -->
  <g transform="translate(290, 110)" filter="url(#shadow)">
    <rect x="0" y="0" width="220" height="420" rx="6" fill="#FFFFFF" stroke="#F59E0B" stroke-width="1.5"/>
    <rect x="0" y="0" width="220" height="34" rx="6" fill="#FFFBEB"/>
    <text x="110" y="22" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#B45309" text-anchor="middle">2. Firebase Auth Platform</text>

    <g transform="translate(15, 50)" font-family="system-ui, sans-serif" font-size="10">
      <rect x="0" y="0" width="190" height="90" rx="4" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1"/>
      <text x="10" y="20" font-weight="700" fill="#0F172A">Token Minting:</text>
      <text x="10" y="36" fill="#475569">• Validate Credentials</text>
      <text x="10" y="52" fill="#475569">• Generate Firebase UID</text>
      <text x="10" y="68" fill="#475569">• Issue JWT ID Token</text>
      <text x="10" y="84" fill="#475569">• Issue Refresh Token</text>

      <rect x="0" y="105" width="190" height="90" rx="4" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1"/>
      <text x="10" y="125" font-weight="700" fill="#0F172A">Identity Security:</text>
      <text x="10" y="141" fill="#475569">• Email Verified Check</text>
      <text x="10" y="157" fill="#475569">• Language set to 'id'</text>
      <text x="10" y="173" fill="#475569">• Password Reset Flow</text>
      <text x="10" y="189" fill="#475569">• Anti-Bruteforce Defense</text>
    </g>
  </g>

  <!-- Step 3: Local Hardware Secure KeyStore -->
  <g transform="translate(555, 110)" filter="url(#shadow)">
    <rect x="0" y="0" width="210" height="420" rx="6" fill="#FFFFFF" stroke="#10B981" stroke-width="1.5"/>
    <rect x="0" y="0" width="210" height="34" rx="6" fill="#ECFDF5"/>
    <text x="105" y="22" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#065F46" text-anchor="middle">3. Secure Local Storage</text>

    <g transform="translate(15, 50)" font-family="system-ui, sans-serif" font-size="10">
      <rect x="0" y="0" width="180" height="90" rx="4" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1"/>
      <text x="10" y="20" font-weight="700" fill="#0F172A">Hardware Vault:</text>
      <text x="10" y="36" fill="#475569">• Android KeyStore (AES)</text>
      <text x="10" y="52" fill="#475569">• EncryptedSharedPreferences</text>
      <text x="10" y="68" fill="#475569">• iOS Keychain Access</text>
      <text x="10" y="84" fill="#475569">• flutter_secure_storage</text>

      <rect x="0" y="105" width="180" height="90" rx="4" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1"/>
      <text x="10" y="125" font-weight="700" fill="#0F172A">Persisted Keys:</text>
      <text x="10" y="141" fill="#475569">• key_user_uid</text>
      <text x="10" y="157" fill="#475569">• key_user_role</text>
      <text x="10" y="173" fill="#475569">• key_user_email</text>
      <text x="10" y="189" fill="#475569">• key_biometric_enabled</text>
    </g>
  </g>

  <!-- Step 4: Server Database & RBAC Rules -->
  <g transform="translate(810, 110)" filter="url(#shadow)">
    <rect x="0" y="0" width="200" height="420" rx="6" fill="#FFFFFF" stroke="#DC2626" stroke-width="1.5"/>
    <rect x="0" y="0" width="200" height="34" rx="6" fill="#FEF2F2"/>
    <text x="100" y="22" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#991B1B" text-anchor="middle">4. Firestore Rules Engine</text>

    <g transform="translate(15, 50)" font-family="system-ui, sans-serif" font-size="10">
      <rect x="0" y="0" width="170" height="90" rx="4" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1"/>
      <text x="10" y="20" font-weight="700" fill="#0F172A">Token Inspection:</text>
      <text x="10" y="36" fill="#475569">• request.auth != null</text>
      <text x="10" y="52" fill="#475569">• request.auth.uid</text>
      <text x="10" y="68" fill="#475569">• request.auth.token</text>
      <text x="10" y="84" fill="#475569">• TLS 1.3 Transmission</text>

      <rect x="0" y="105" width="170" height="110" rx="4" fill="#FEF2F2" stroke="#EF4444" stroke-width="1"/>
      <text x="10" y="125" font-weight="700" fill="#991B1B">Strict 2-Role RBAC:</text>
      <text x="10" y="141" fill="#7F1D1D">• isOwner(userId) for</text>
      <text x="10" y="155" fill="#7F1D1D">  users/{{uid}}/meals</text>
      <text x="10" y="171" fill="#7F1D1D">• isAdmin() evaluates</text>
      <text x="10" y="185" fill="#7F1D1D">  users/{{uid}}.role</text>
      <text x="10" y="201" fill="#7F1D1D">• Anti-escalation shield</text>
    </g>
  </g>

  <!-- Connecting Arrows -->
  <line x1="245" y1="200" x2="290" y2="200" stroke="#2563EB" stroke-width="2" marker-end="url(#arr-flow)"/>
  <line x1="510" y1="200" x2="555" y2="200" stroke="#2563EB" stroke-width="2" marker-end="url(#arr-flow)"/>
  <line x1="765" y1="200" x2="810" y2="200" stroke="#2563EB" stroke-width="2" marker-end="url(#arr-flow)"/>

  <rect x="250" y="175" width="35" height="18" rx="2" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1"/>
  <text x="267" y="188" font-family="system-ui, sans-serif" font-size="8.5" font-weight="700" fill="#1E40AF" text-anchor="middle">Auth</text>

  <rect x="515" y="175" width="35" height="18" rx="2" fill="#ECFDF5" stroke="#10B981" stroke-width="1"/>
  <text x="532" y="188" font-family="system-ui, sans-serif" font-size="8.5" font-weight="700" fill="#065F46" text-anchor="middle">Token</text>

  <rect x="770" y="175" width="35" height="18" rx="2" fill="#FEF2F2" stroke="#EF4444" stroke-width="1"/>
  <text x="787" y="188" font-family="system-ui, sans-serif" font-size="8.5" font-weight="700" fill="#991B1B" text-anchor="middle">Rules</text>
</svg>"""
    svg_path = os.path.join(OUTPUT_DIR, "fig8_token_flow.svg")
    png_path = os.path.join(OUTPUT_DIR, "fig8_token_flow.png")
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(svg)
    render_svg_to_png(svg_path, png_path, w, h)


# ==========================================
# 8. Hierarchical Document Tree Schema
# ==========================================
def generate_database_schema_tree():
    w, h = 1050, 620
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <defs>
    <filter id="shadow" x="-3%" y="-3%" width="106%" height="106%">
      <feDropShadow dx="2" dy="2" stdDeviation="2" flood-color="#0F172A" flood-opacity="0.08"/>
    </filter>
  </defs>

  <rect width="{w}" height="{h}" fill="#F8FAFC"/>
  <rect x="15" y="15" width="{w-30}" height="{h-30}" rx="10" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>

  <!-- Title Header -->
  <rect x="15" y="15" width="{w-30}" height="55" rx="10" fill="#0F172A"/>
  <rect x="15" y="55" width="{w-30}" height="15" fill="#0F172A"/>
  <text x="35" y="48" font-family="system-ui, sans-serif" font-size="18" font-weight="700" fill="#FFFFFF">NutriView — Cloud Firestore Hierarchical Document Tree</text>
  <text x="{w-35}" y="48" font-family="system-ui, sans-serif" font-size="13" font-weight="500" fill="#94A3B8" text-anchor="end">Database Path &amp; Collection Structure</text>

  <!-- Root Firestore Node -->
  <g transform="translate(45, 95)" filter="url(#shadow)">
    <rect x="0" y="0" width="960" height="45" rx="6" fill="#0F172A"/>
    <text x="25" y="28" font-family="system-ui, sans-serif" font-size="14" font-weight="700" fill="#FFFFFF">/databases/(default)/documents</text>
    <text x="935" y="28" font-family="system-ui, sans-serif" font-size="12" font-weight="600" fill="#38BDF8" text-anchor="end">Cloud Firestore Root (asia-southeast2)</text>
  </g>

  <!-- Branches -->
  <!-- Branch 1: users -->
  <g transform="translate(65, 160)" filter="url(#shadow)">
    <rect x="0" y="0" width="450" height="230" rx="6" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.5"/>
    <text x="15" y="24" font-family="monospace" font-size="12" font-weight="700" fill="#1E40AF">📁 users (Collection)</text>
    
    <rect x="25" y="38" width="405" height="75" rx="4" fill="#FFFFFF" stroke="#93C5FD" stroke-width="1.2"/>
    <text x="38" y="58" font-family="monospace" font-size="11" font-weight="700" fill="#0F172A">📄 {{userId}} (Document)</text>
    <text x="38" y="74" font-family="system-ui" font-size="9.5" fill="#475569">Fields: uid, email, full_name, role ('user'|'admin'), is_active</text>
    <text x="38" y="88" font-family="system-ui" font-size="9.5" fill="#475569">Embedded: profile map (age, TB, BB, goal), daily_target map</text>
    <text x="38" y="102" font-family="system-ui" font-size="9.5" font-weight="600" fill="#2563EB">Rules: Owner can read own doc; Admin can view all</text>

    <!-- Subcollection: meals -->
    <rect x="50" y="125" width="380" height="90" rx="4" fill="#ECFDF5" stroke="#10B981" stroke-width="1.2"/>
    <text x="65" y="145" font-family="monospace" font-size="11" font-weight="700" fill="#065F46">📁 meals (Private Subcollection)</text>
    <text x="75" y="165" font-family="monospace" font-size="10" font-weight="700" fill="#0F172A">📄 {{mealId}} (Document)</text>
    <text x="75" y="181" font-family="system-ui" font-size="9" fill="#334155">• Fields: meal_type, consumed_date (Indexed), consumed_at, totals</text>
    <text x="75" y="195" font-family="system-ui" font-size="9" fill="#334155">• items: array&lt;map&gt; (food_id, grams, scaled calories, P, C, F, conf)</text>
    <text x="75" y="207" font-family="system-ui" font-size="9" font-weight="600" fill="#059669">Strict Isolation: allow read, write: if request.auth.uid == userId</text>
  </g>

  <!-- Branch 2: foods -->
  <g transform="translate(540, 160)" filter="url(#shadow)">
    <rect x="0" y="0" width="450" height="105" rx="6" fill="#FFFBEB" stroke="#F59E0B" stroke-width="1.5"/>
    <text x="15" y="24" font-family="monospace" font-size="12" font-weight="700" fill="#92400E">📁 foods (Public Master Catalog Collection)</text>
    
    <rect x="25" y="38" width="405" height="55" rx="4" fill="#FFFFFF" stroke="#FCD34D" stroke-width="1.2"/>
    <text x="38" y="58" font-family="monospace" font-size="11" font-weight="700" fill="#0F172A">📄 {{foodId}} (Document)</text>
    <text x="38" y="74" font-family="system-ui" font-size="9.5" fill="#475569">Fields: id, name, yolo_class, is_active, 100g macros, source: 'TKPI 2020'</text>
    <text x="38" y="88" font-family="system-ui" font-size="9.5" font-weight="600" fill="#D97706">Rules: allow read: if true; allow write: if isAdmin()</text>
  </g>

  <!-- Branch 3: cms_articles -->
  <g transform="translate(540, 280)" filter="url(#shadow)">
    <rect x="0" y="0" width="450" height="110" rx="6" fill="#F5F3FF" stroke="#8B5CF6" stroke-width="1.5"/>
    <text x="15" y="24" font-family="monospace" font-size="12" font-weight="700" fill="#6D28D9">📁 cms_articles (Nutrition Articles Collection)</text>
    
    <rect x="25" y="38" width="405" height="60" rx="4" fill="#FFFFFF" stroke="#C4B5FD" stroke-width="1.2"/>
    <text x="38" y="58" font-family="monospace" font-size="11" font-weight="700" fill="#0F172A">📄 {{articleId}} (Document)</text>
    <text x="38" y="74" font-family="system-ui" font-size="9.5" fill="#475569">Fields: title, slug, status ('published'|'draft'), cover_image_url, content</text>
    <text x="38" y="88" font-family="system-ui" font-size="9.5" font-weight="600" fill="#7C3AED">Rules: allow read: if true; allow write: if isAdmin()</text>
  </g>

  <!-- Branch 4: Governance & Supporting (Bottom Row) -->
  <g transform="translate(65, 410)" filter="url(#shadow)">
    <!-- cms_audit_logs -->
    <rect x="0" y="0" width="300" height="150" rx="6" fill="#FEF2F2" stroke="#EF4444" stroke-width="1.5"/>
    <text x="15" y="24" font-family="monospace" font-size="11.5" font-weight="700" fill="#991B1B">📁 cms_audit_logs (Immutable)</text>
    <rect x="15" y="36" width="270" height="100" rx="4" fill="#FFFFFF" stroke="#FCA5A5" stroke-width="1"/>
    <text x="25" y="56" font-family="monospace" font-size="10.5" font-weight="700" fill="#0F172A">📄 {{logId}} (Document)</text>
    <text x="25" y="72" font-family="system-ui" font-size="9" fill="#475569">Fields: performed_by, action, target,</text>
    <text x="25" y="86" font-family="system-ui" font-size="9" fill="#475569">timestamp, details map</text>
    <text x="25" y="104" font-family="system-ui" font-size="9" font-weight="700" fill="#DC2626">Rules: update, delete: if false;</text>
    <text x="25" y="118" font-family="system-ui" font-size="8.5" fill="#7F1D1D">Only Admin can read &amp; create audit entry</text>
  </g>

  <g transform="translate(390, 410)" filter="url(#shadow)">
    <!-- cms_categories & cms_announcements -->
    <rect x="0" y="0" width="295" height="150" rx="6" fill="#F8FAFC" stroke="#64748B" stroke-width="1.5"/>
    <text x="15" y="24" font-family="monospace" font-size="11.5" font-weight="700" fill="#334155">📁 cms_categories &amp; cms_announcements</text>
    <rect x="15" y="36" width="265" height="100" rx="4" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1"/>
    <text x="25" y="56" font-family="monospace" font-size="10" font-weight="700" fill="#0F172A">📄 {{categoryId}} / {{announcementId}}</text>
    <text x="25" y="74" font-family="system-ui" font-size="9" fill="#475569">• Category Taxonomy: name, slug</text>
    <text x="25" y="90" font-family="system-ui" font-size="9" fill="#475569">• System Banner Alerts: title, is_active</text>
    <text x="25" y="108" font-family="system-ui" font-size="9" font-weight="600" fill="#475569">Rules: read: true; write: if isAdmin()</text>
  </g>

  <g transform="translate(710, 410)" filter="url(#shadow)">
    <!-- cms_media -->
    <rect x="0" y="0" width="280" height="150" rx="6" fill="#F8FAFC" stroke="#64748B" stroke-width="1.5"/>
    <text x="15" y="24" font-family="monospace" font-size="11.5" font-weight="700" fill="#334155">📁 cms_media (External Asset URLs)</text>
    <rect x="15" y="36" width="250" height="100" rx="4" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1"/>
    <text x="25" y="56" font-family="monospace" font-size="10" font-weight="700" fill="#0F172A">📄 {{mediaId}} (Document)</text>
    <text x="25" y="74" font-family="system-ui" font-size="9" fill="#475569">• Fields: url (HTTPS), file_name,</text>
    <text x="25" y="88" font-family="system-ui" font-size="9" fill="#475569">  uploaded_by, created_at</text>
    <text x="25" y="106" font-family="system-ui" font-size="9" font-weight="600" fill="#047857">Replaces Storage Bucket Completely</text>
    <text x="25" y="120" font-family="system-ui" font-size="8.5" fill="#15803D">Rules: read: true; write: if isAdmin()</text>
  </g>
</svg>"""
    svg_path = os.path.join(OUTPUT_DIR, "fig9_database_schema.svg")
    png_path = os.path.join(OUTPUT_DIR, "fig9_database_schema.png")
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(svg)
    render_svg_to_png(svg_path, png_path, w, h)


# ==========================================
# 9. Declarative Security Rules (RBAC) Flow
# ==========================================
def generate_security_rules_flow():
    w, h = 1050, 580
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <defs>
    <marker id="arr-rule" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#1E293B"/>
    </marker>
    <filter id="shadow" x="-3%" y="-3%" width="106%" height="106%">
      <feDropShadow dx="2" dy="2" stdDeviation="2" flood-color="#0F172A" flood-opacity="0.08"/>
    </filter>
  </defs>

  <rect width="{w}" height="{h}" fill="#F8FAFC"/>
  <rect x="15" y="15" width="{w-30}" height="{h-30}" rx="10" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>

  <!-- Title Header -->
  <rect x="15" y="15" width="{w-30}" height="55" rx="10" fill="#0F172A"/>
  <rect x="15" y="55" width="{w-30}" height="15" fill="#0F172A"/>
  <text x="35" y="48" font-family="system-ui, sans-serif" font-size="18" font-weight="700" fill="#FFFFFF">NutriView — Declarative Security Rules Evaluation Matrix</text>
  <text x="{w-35}" y="48" font-family="system-ui, sans-serif" font-size="13" font-weight="500" fill="#94A3B8" text-anchor="end">Strict 2-Role RBAC &amp; Anti-Privilege Escalation</text>

  <!-- Incoming Firestore Request -->
  <g transform="translate(40, 100)" filter="url(#shadow)">
    <rect x="0" y="0" width="180" height="60" rx="6" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.5"/>
    <text x="90" y="26" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#1E40AF" text-anchor="middle">Incoming Request</text>
    <text x="90" y="42" font-family="system-ui, sans-serif" font-size="9.5" fill="#2563EB" text-anchor="middle">read / create / update / delete</text>
  </g>

  <!-- Decision 1: isSignedIn() -->
  <g transform="translate(260, 95)" filter="url(#shadow)">
    <path d="M 60 0 L 120 35 L 60 70 L 0 35 Z" fill="#F8FAFC" stroke="#475569" stroke-width="1.5"/>
    <text x="60" y="32" font-family="monospace" font-size="10" font-weight="700" fill="#0F172A" text-anchor="middle">isSignedIn()?</text>
    <text x="60" y="46" font-family="system-ui" font-size="8" fill="#64748B" text-anchor="middle">auth != null</text>
  </g>

  <line x1="220" y1="130" x2="260" y2="130" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-rule)"/>

  <!-- Decision 2: Target Path Branching -->
  <g transform="translate(420, 90)" filter="url(#shadow)">
    <rect x="0" y="0" width="160" height="80" rx="6" fill="#F1F5F9" stroke="#64748B" stroke-width="1.5"/>
    <text x="80" y="24" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#0F172A" text-anchor="middle">Evaluate Path Match:</text>
    <text x="80" y="42" font-family="monospace" font-size="9" fill="#334155">• /users/{{userId}}</text>
    <text x="80" y="56" font-family="monospace" font-size="9" fill="#059669">• .../meals/{{mealId}}</text>
    <text x="80" y="70" font-family="monospace" font-size="9" fill="#D97706">• /foods, /cms_*</text>
  </g>

  <line x1="380" y1="130" x2="420" y2="130" stroke="#1E293B" stroke-width="1.5" marker-end="url(#arr-rule)"/>
  <text x="395" y="122" font-family="system-ui, sans-serif" font-size="9" font-weight="600" fill="#16A34A">Yes</text>

  <!-- Deny if not signed in (for protected paths) -->
  <line x1="320" y1="165" x2="320" y2="240" stroke="#DC2626" stroke-width="1.5"/>
  <line x1="320" y1="240" x2="420" y2="240" stroke="#DC2626" stroke-width="1.5" marker-end="url(#arr-rule)"/>
  <text x="325" y="200" font-family="system-ui, sans-serif" font-size="9" font-weight="600" fill="#DC2626">No (Anon)</text>

  <rect x="420" y="220" width="160" height="40" rx="4" fill="#FEF2F2" stroke="#EF4444" stroke-width="1.5"/>
  <text x="500" y="244" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#991B1B" text-anchor="middle">DENIED / REJECTED</text>

  <!-- 3 Path Evaluation Columns on Right -->
  <!-- Column 1: /users/{{userId}}/meals/{{mealId}} (Strict Tenant Isolation) -->
  <g transform="translate(630, 90)" filter="url(#shadow)">
    <rect x="0" y="0" width="370" height="135" rx="6" fill="#ECFDF5" stroke="#10B981" stroke-width="1.5"/>
    <text x="15" y="24" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#065F46">Rule A: User Meals Subcollection</text>
    <rect x="15" y="34" width="340" height="88" rx="4" fill="#FFFFFF" stroke="#A7F3D0" stroke-width="1"/>
    <text x="25" y="54" font-family="monospace" font-size="10" font-weight="bold" fill="#0F172A">isOwner(userId):</text>
    <text x="25" y="70" font-family="monospace" font-size="9.5" fill="#047857">allow read, write: if request.auth.uid == userId</text>
    <text x="25" y="88" font-family="system-ui" font-size="9" fill="#334155">✓ Guarantees multi-tenant isolation across all end users.</text>
    <text x="25" y="104" font-family="system-ui" font-size="9" fill="#334155">✗ User cannot query, read or tamper with another's meals.</text>
  </g>

  <!-- Column 2: /users/{{userId}} (Anti-Escalation) -->
  <g transform="translate(630, 240)" filter="url(#shadow)">
    <rect x="0" y="0" width="370" height="145" rx="6" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.5"/>
    <text x="15" y="24" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#1E40AF">Rule B: User Registration &amp; Role Updates</text>
    <rect x="15" y="34" width="340" height="98" rx="4" fill="#FFFFFF" stroke="#BFDBFE" stroke-width="1"/>
    <text x="25" y="52" font-family="monospace" font-size="9.5" font-weight="bold" fill="#0F172A">Create: role == 'user' &amp;&amp; is_active == true</text>
    <text x="25" y="68" font-family="monospace" font-size="9.5" font-weight="bold" fill="#0F172A">Update: request.role == resource.role</text>
    <text x="25" y="86" font-family="system-ui" font-size="9" fill="#334155">✓ Prevents self-elevation from 'user' to 'admin'.</text>
    <text x="25" y="100" font-family="system-ui" font-size="9" fill="#334155">✓ Admin can view all users and toggle active state.</text>
    <text x="25" y="114" font-family="system-ui" font-size="9" fill="#334155">✓ Account delete permitted for Owner and Admin.</text>
  </g>

  <!-- Column 3: Administrative & Governance Collections -->
  <g transform="translate(630, 400)" filter="url(#shadow)">
    <rect x="0" y="0" width="370" height="155" rx="6" fill="#FEF2F2" stroke="#EF4444" stroke-width="1.5"/>
    <text x="15" y="24" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#991B1B">Rule C: Master Catalog &amp; Immutable Audit Logs</text>
    <rect x="15" y="34" width="340" height="108" rx="4" fill="#FFFFFF" stroke="#FECACA" stroke-width="1"/>
    <text x="25" y="52" font-family="monospace" font-size="9.5" font-weight="bold" fill="#0F172A">isAdmin(): getUserData().role == 'admin'</text>
    <text x="25" y="68" font-family="system-ui" font-size="9" fill="#334155">• foods, cms_articles: allow read: if true; write: if isAdmin()</text>
    <text x="25" y="84" font-family="system-ui" font-size="9" fill="#334155">• cms_audit_logs: update, delete: if false (IMMUTABLE)</text>
    <text x="25" y="100" font-family="system-ui" font-size="9" fill="#334155">• Default Deny: match /{{document=**}} {{ allow: false; }}</text>
    <text x="25" y="116" font-family="system-ui" font-size="9" font-weight="700" fill="#DC2626">100% Verified across 359 automated test cases (42 files).</text>
  </g>

  <!-- Connectors from Target Path to Rules -->
  <line x1="580" y1="110" x2="630" y2="110" stroke="#10B981" stroke-width="1.5" marker-end="url(#arr-rule)"/>
  <line x1="580" y1="130" x2="605" y2="130" stroke="#2563EB" stroke-width="1.5"/>
  <line x1="605" y1="130" x2="605" y2="280" stroke="#2563EB" stroke-width="1.5"/>
  <line x1="605" y1="280" x2="630" y2="280" stroke="#2563EB" stroke-width="1.5" marker-end="url(#arr-rule)"/>

  <line x1="580" y1="150" x2="595" y2="150" stroke="#DC2626" stroke-width="1.5"/>
  <line x1="595" y1="150" x2="595" y2="440" stroke="#DC2626" stroke-width="1.5"/>
  <line x1="595" y1="440" x2="630" y2="440" stroke="#DC2626" stroke-width="1.5" marker-end="url(#arr-rule)"/>
</svg>"""
    svg_path = os.path.join(OUTPUT_DIR, "fig10_security_rules.svg")
    png_path = os.path.join(OUTPUT_DIR, "fig10_security_rules.png")
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(svg)
    render_svg_to_png(svg_path, png_path, w, h)


# ==========================================
# 10. Offline Storage & Fallback Architecture
# ==========================================
def generate_offline_storage_flow():
    w, h = 1050, 580
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <defs>
    <marker id="arr-cache" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#1E293B"/>
    </marker>
    <filter id="shadow" x="-3%" y="-3%" width="106%" height="106%">
      <feDropShadow dx="2" dy="2" stdDeviation="2" flood-color="#0F172A" flood-opacity="0.08"/>
    </filter>
  </defs>

  <rect width="{w}" height="{h}" fill="#F8FAFC"/>
  <rect x="15" y="15" width="{w-30}" height="{h-30}" rx="10" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>

  <!-- Title Header -->
  <rect x="15" y="15" width="{w-30}" height="55" rx="10" fill="#0F172A"/>
  <rect x="15" y="55" width="{w-30}" height="15" fill="#0F172A"/>
  <text x="35" y="48" font-family="system-ui, sans-serif" font-size="18" font-weight="700" fill="#FFFFFF">NutriView — Offline-First Persistence &amp; Fallback Architecture</text>
  <text x="{w-35}" y="48" font-family="system-ui, sans-serif" font-size="13" font-weight="500" fill="#94A3B8" text-anchor="end">100 MB Bounded Cache &amp; Seed Food Fallback</text>

  <!-- 3 Architectural Pillars -->
  <!-- Pillar 1: Model & Food Catalog Fallback -->
  <g transform="translate(45, 95)" filter="url(#shadow)">
    <rect x="0" y="0" width="300" height="440" rx="8" fill="#FFFBEB" stroke="#F59E0B" stroke-width="1.5"/>
    <rect x="0" y="0" width="300" height="34" rx="8" fill="#FEF3C7"/>
    <text x="150" y="22" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#92400E" text-anchor="middle">1. Edge AI &amp; Catalog Asset Fallback</text>

    <g transform="translate(15, 50)" font-family="system-ui, sans-serif" font-size="10">
      <rect x="0" y="0" width="270" height="85" rx="4" fill="#FFFFFF" stroke="#FDE68A" stroke-width="1"/>
      <text x="12" y="20" font-weight="700" fill="#92400E">Model best.tflite (9.4 MB):</text>
      <text x="12" y="38" fill="#475569">• Bundled locally in Android asset package</text>
      <text x="12" y="52" fill="#475569">• 0 KB network download required</text>
      <text x="12" y="66" fill="#475569">• Fully operative in Airplane Mode</text>

      <rect x="0" y="98" width="270" height="110" rx="4" fill="#FFFFFF" stroke="#FDE68A" stroke-width="1"/>
      <text x="12" y="118" font-weight="700" fill="#92400E">Catalog seed_foods.json:</text>
      <text x="12" y="136" fill="#475569">• 29 Local Indonesian Foods</text>
      <text x="12" y="150" fill="#475569">• Complete TKPI 2020 Nutrition Data</text>
      <text x="12" y="164" fill="#475569">• Automatic Fallback if Firestore is empty</text>
      <text x="12" y="178" fill="#475569">  or network connection times out</text>
      <text x="12" y="194" font-weight="600" fill="#B45309">• 0 Interruption to Detection Flow</text>

      <rect x="0" y="220" width="270" height="155" rx="4" fill="#FFFFFF" stroke="#FDE68A" stroke-width="1"/>
      <text x="12" y="240" font-weight="700" fill="#92400E">FoodRepository Strategy:</text>
      <text x="12" y="258" font-family="monospace" font-size="9" fill="#1E293B">try {{</text>
      <text x="24" y="272" font-family="monospace" font-size="9" fill="#1E293B">  query Cloud Firestore</text>
      <text x="12" y="286" font-family="monospace" font-size="9" fill="#1E293B">}} catch (e) {{</text>
      <text x="24" y="300" font-family="monospace" font-size="9" fill="#047857">  loadFromLocalAsset()</text>
      <text x="12" y="314" font-family="monospace" font-size="9" fill="#1E293B">}}</text>
      <text x="12" y="338" font-weight="600" fill="#065F46">Seamless user experience offline.</text>
    </g>
  </g>

  <!-- Pillar 2: 100 MB Bounded Cache (main.dart) -->
  <g transform="translate(370, 95)" filter="url(#shadow)">
    <rect x="0" y="0" width="300" height="440" rx="8" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.5"/>
    <rect x="0" y="0" width="300" height="34" rx="8" fill="#DBEAFE"/>
    <text x="150" y="22" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#1E40AF" text-anchor="middle">2. Bounded Cache Configuration</text>

    <g transform="translate(15, 50)" font-family="system-ui, sans-serif" font-size="10">
      <rect x="0" y="0" width="270" height="110" rx="4" fill="#FFFFFF" stroke="#BFDBFE" stroke-width="1"/>
      <text x="12" y="20" font-weight="700" fill="#1E40AF">Production Cache Settings:</text>
      <text x="12" y="38" font-family="monospace" font-size="9" fill="#0F172A">FirebaseFirestore.instance</text>
      <text x="12" y="52" font-family="monospace" font-size="9" fill="#0F172A">.settings = const Settings(</text>
      <text x="24" y="66" font-family="monospace" font-size="9" font-weight="bold" fill="#2563EB">persistenceEnabled: true,</text>
      <text x="24" y="80" font-family="monospace" font-size="9" font-weight="bold" fill="#2563EB">cacheSizeBytes: 104857600,</text>
      <text x="12" y="94" font-family="monospace" font-size="9" fill="#0F172A">);</text>

      <rect x="0" y="122" width="270" height="120" rx="4" fill="#FFFFFF" stroke="#BFDBFE" stroke-width="1"/>
      <text x="12" y="142" font-weight="700" fill="#1E40AF">Why Bounded at 100 MB?</text>
      <text x="12" y="160" fill="#475569">• Prevents unbounded storage growth</text>
      <text x="12" y="174" fill="#475569">• Default cache in older versions</text>
      <text x="12" y="188" fill="#475569">  could consume gigabytes of flash</text>
      <text x="12" y="202" fill="#475569">• Automatic Least-Recently-Used (LRU)</text>
      <text x="12" y="216" fill="#475569">  eviction keeps database fast and lean</text>
      <text x="12" y="230" font-weight="600" fill="#0369A1">• Complies with Google Play store policy</text>

      <rect x="0" y="254" width="270" height="120" rx="4" fill="#FFFFFF" stroke="#BFDBFE" stroke-width="1"/>
      <text x="12" y="274" font-weight="700" fill="#1E40AF">Local SQLite Indexing:</text>
      <text x="12" y="292" fill="#475569">• Instant local query responses (&lt; 5ms)</text>
      <text x="12" y="306" fill="#475569">• Historical meals filtered by consumed_date</text>
      <text x="12" y="320" fill="#475569">• 95% reduction in cloud reads</text>
      <text x="12" y="334" fill="#475569">• Keeps app on $0 Firebase Spark Tier</text>
    </g>
  </g>

  <!-- Pillar 3: Offline Write Mutation & Background Sync -->
  <g transform="translate(695, 95)" filter="url(#shadow)">
    <rect x="0" y="0" width="300" height="440" rx="8" fill="#ECFDF5" stroke="#10B981" stroke-width="1.5"/>
    <rect x="0" y="0" width="300" height="34" rx="8" fill="#D1FAE5"/>
    <text x="150" y="22" font-family="system-ui, sans-serif" font-size="12" font-weight="700" fill="#065F46" text-anchor="middle">3. Offline Write &amp; Auto-Sync</text>

    <g transform="translate(15, 50)" font-family="system-ui, sans-serif" font-size="10">
      <rect x="0" y="0" width="270" height="95" rx="4" fill="#FFFFFF" stroke="#A7F3D0" stroke-width="1"/>
      <text x="12" y="20" font-weight="700" fill="#065F46">Write Flow while Offline:</text>
      <text x="12" y="36" fill="#475569">• User confirms meal portion</text>
      <text x="12" y="50" fill="#475569">• MealRepository writes to local cache</text>
      <text x="12" y="64" fill="#475569">• Local mutation queue saves state</text>
      <text x="12" y="78" fill="#475569">• UI updates immediately without lag</text>

      <rect x="0" y="108" width="270" height="110" rx="4" fill="#FFFFFF" stroke="#A7F3D0" stroke-width="1"/>
      <text x="12" y="128" font-weight="700" fill="#065F46">Automatic Cloud Reconnection:</text>
      <text x="12" y="146" fill="#475569">• Network connectivity restored</text>
      <text x="12" y="160" fill="#475569">• Firestore SDK syncs queue in background</text>
      <text x="12" y="174" fill="#475569">• Conflict resolution via server timestamp</text>
      <text x="12" y="188" fill="#475569">• 0 data loss guaranteed</text>

      <rect x="0" y="230" width="270" height="145" rx="4" fill="#FFFFFF" stroke="#A7F3D0" stroke-width="1"/>
      <text x="12" y="250" font-weight="700" fill="#065F46">Security Rule Compliance:</text>
      <text x="12" y="268" fill="#475569">• Security rules re-evaluated on server sync</text>
      <text x="12" y="282" fill="#475569">• Offline writes cannot forge roles</text>
      <text x="12" y="296" fill="#475569">• Auth UID verified upon reconnect</text>
      <text x="12" y="310" fill="#475569">• Invalid mutations dropped safely</text>
      <text x="12" y="332" font-weight="600" fill="#047857">100% Passed in simulated flight mode.</text>
    </g>
  </g>
</svg>"""
    svg_path = os.path.join(OUTPUT_DIR, "fig11_offline_storage.svg")
    png_path = os.path.join(OUTPUT_DIR, "fig11_offline_storage.png")
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(svg)
    render_svg_to_png(svg_path, png_path, w, h)


# ==========================================
# 11. Scanner & Meal Logging Sequence
# ==========================================
def generate_scan_sequence():
    w, h = 1100, 720
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <defs>
    <marker id="arr-sync" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#0F172A"/>
    </marker>
    <marker id="arr-reply" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 1 L 8 5 L 0 9 z" fill="#2563EB"/>
    </marker>
    <filter id="shadow" x="-3%" y="-3%" width="106%" height="106%">
      <feDropShadow dx="2" dy="2" stdDeviation="2" flood-color="#0F172A" flood-opacity="0.08"/>
    </filter>
  </defs>

  <rect width="{w}" height="{h}" fill="#F8FAFC"/>
  <rect x="15" y="15" width="{w-30}" height="{h-30}" rx="10" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5"/>

  <!-- Title Header -->
  <rect x="15" y="15" width="{w-30}" height="55" rx="10" fill="#0F172A"/>
  <rect x="15" y="55" width="{w-30}" height="15" fill="#0F172A"/>
  <text x="35" y="48" font-family="system-ui, sans-serif" font-size="18" font-weight="700" fill="#FFFFFF">NutriView — UML Sequence Diagram: Computer Vision &amp; Meal Logging</text>
  <text x="{w-35}" y="48" font-family="system-ui, sans-serif" font-size="13" font-weight="500" fill="#94A3B8" text-anchor="end">Asynchronous Isolate Offloading &amp; Multi-Tenant Write</text>

  <!-- Participants Definition (X positions) -->
  <!-- User: 90, ScannerScreen: 230, ScanFlowProvider: 390, Worker Isolate: 560, FoodRepo: 720, MealRepo: 870, Firestore: 1000 -->
  
  <!-- Participant Boxes -->
  <!-- 1. User -->
  <g transform="translate(45, 90)">
    <rect x="0" y="0" width="90" height="38" rx="4" fill="#0F172A"/>
    <text x="45" y="24" font-family="system-ui, sans-serif" font-size="11" font-weight="700" fill="#FFFFFF" text-anchor="middle">actor User</text>
  </g>

  <!-- 2. ScannerScreen -->
  <g transform="translate(175, 90)">
    <rect x="0" y="0" width="110" height="38" rx="4" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.5"/>
    <text x="55" y="16" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#1E40AF" text-anchor="middle">&lt;&lt;boundary&gt;&gt;</text>
    <text x="55" y="30" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#1E40AF" text-anchor="middle">ScannerScreen</text>
  </g>

  <!-- 3. ScanFlowProvider -->
  <g transform="translate(325, 90)">
    <rect x="0" y="0" width="130" height="38" rx="4" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.5"/>
    <text x="65" y="16" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#1E40AF" text-anchor="middle">&lt;&lt;control&gt;&gt;</text>
    <text x="65" y="30" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#1E40AF" text-anchor="middle">ScanFlowProvider</text>
  </g>

  <!-- 4. Worker Isolate / YOLO26n -->
  <g transform="translate(490, 90)">
    <rect x="0" y="0" width="140" height="38" rx="4" fill="#FFFBEB" stroke="#F59E0B" stroke-width="1.5"/>
    <text x="70" y="16" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#92400E" text-anchor="middle">&lt;&lt;isolate&gt;&gt;</text>
    <text x="70" y="30" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#92400E" text-anchor="middle">Worker Isolate (YOLO)</text>
  </g>

  <!-- 5. FoodRepository -->
  <g transform="translate(665, 90)">
    <rect x="0" y="0" width="110" height="38" rx="4" fill="#F1F5F9" stroke="#64748B" stroke-width="1.5"/>
    <text x="55" y="16" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#334155" text-anchor="middle">&lt;&lt;entity&gt;&gt;</text>
    <text x="55" y="30" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#334155">FoodRepository</text>
  </g>

  <!-- 6. MealRepository -->
  <g transform="translate(815, 90)">
    <rect x="0" y="0" width="110" height="38" rx="4" fill="#F1F5F9" stroke="#64748B" stroke-width="1.5"/>
    <text x="55" y="16" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#334155" text-anchor="middle">&lt;&lt;entity&gt;&gt;</text>
    <text x="55" y="30" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#334155">MealRepository</text>
  </g>

  <!-- 7. Cloud Firestore / Cache -->
  <g transform="translate(945, 90)">
    <rect x="0" y="0" width="120" height="38" rx="4" fill="#ECFDF5" stroke="#10B981" stroke-width="1.5"/>
    <text x="60" y="16" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#065F46" text-anchor="middle">&lt;&lt;database&gt;&gt;</text>
    <text x="60" y="30" font-family="system-ui, sans-serif" font-size="10" font-weight="700" fill="#065F46">Cloud Firestore</text>
  </g>

  <!-- Lifeline dashed lines -->
  <line x1="90" y1="128" x2="90" y2="670" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="4 4"/>
  <line x1="230" y1="128" x2="230" y2="670" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="4 4"/>
  <line x1="390" y1="128" x2="390" y2="670" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="4 4"/>
  <line x1="560" y1="128" x2="560" y2="670" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="4 4"/>
  <line x1="720" y1="128" x2="720" y2="670" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="4 4"/>
  <line x1="870" y1="128" x2="870" y2="670" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="4 4"/>
  <line x1="1005" y1="128" x2="1005" y2="670" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="4 4"/>

  <!-- Activation Bars -->
  <!-- User -->
  <rect x="85" y="145" width="10" height="70" fill="#CBD5E1" stroke="#475569" stroke-width="1"/>
  <rect x="85" y="380" width="10" height="90" fill="#CBD5E1" stroke="#475569" stroke-width="1"/>

  <!-- ScannerScreen -->
  <rect x="225" y="145" width="10" height="85" fill="#BFDBFE" stroke="#2563EB" stroke-width="1"/>
  <rect x="225" y="360" width="10" height="130" fill="#BFDBFE" stroke="#2563EB" stroke-width="1"/>

  <!-- ScanFlowProvider -->
  <rect x="385" y="160" width="10" height="190" fill="#BFDBFE" stroke="#2563EB" stroke-width="1"/>
  <rect x="385" y="470" width="10" height="175" fill="#BFDBFE" stroke="#2563EB" stroke-width="1"/>

  <!-- Worker Isolate -->
  <rect x="555" y="180" width="10" height="95" fill="#FDE68A" stroke="#D97706" stroke-width="1"/>

  <!-- FoodRepo -->
  <rect x="715" y="295" width="10" height="40" fill="#E2E8F0" stroke="#64748B" stroke-width="1"/>

  <!-- MealRepo -->
  <rect x="865" y="520" width="10" height="100" fill="#E2E8F0" stroke="#64748B" stroke-width="1"/>

  <!-- Firestore -->
  <rect x="1000" y="540" width="10" height="60" fill="#A7F3D0" stroke="#10B981" stroke-width="1"/>

  <!-- Sequence Messages -->
  <!-- 1. User -> ScannerScreen -->
  <line x1="95" y1="155" x2="225" y2="155" stroke="#0F172A" stroke-width="1.5" marker-end="url(#arr-sync)"/>
  <text x="160" y="150" font-family="system-ui, sans-serif" font-size="9.5" font-weight="600" fill="#0F172A" text-anchor="middle">1: Capture / Pick Image</text>

  <!-- 2. ScannerScreen -> ScanFlowProvider -->
  <line x1="235" y1="170" x2="385" y2="170" stroke="#0F172A" stroke-width="1.5" marker-end="url(#arr-sync)"/>
  <text x="310" y="165" font-family="system-ui, sans-serif" font-size="9.5" font-weight="600" fill="#0F172A" text-anchor="middle">2: detectFood(imageBytes)</text>

  <!-- 3. ScanFlowProvider -> Worker Isolate -->
  <line x1="395" y1="185" x2="555" y2="185" stroke="#0F172A" stroke-width="1.5" marker-end="url(#arr-sync)"/>
  <text x="475" y="180" font-family="system-ui, sans-serif" font-size="9" font-weight="600" fill="#B45309" text-anchor="middle">3: Isolate.run(_preprocess &amp; TFLite)</text>

  <!-- Self-call on Worker Isolate -->
  <path d="M 565 200 L 595 200 L 595 240 L 565 240" stroke="#D97706" stroke-width="1.3" fill="none" marker-end="url(#arr-sync)"/>
  <text x="600" y="215" font-family="system-ui, sans-serif" font-size="8.5" fill="#78350F">Interpreter.run()</text>
  <text x="600" y="228" font-family="system-ui, sans-serif" font-size="8.5" fill="#78350F">NMS IoU 0.45</text>

  <!-- 4. Worker Isolate -> ScanFlowProvider (Reply) -->
  <line x1="555" y1="270" x2="395" y2="270" stroke="#2563EB" stroke-width="1.5" stroke-dasharray="4 3" marker-end="url(#arr-reply)"/>
  <text x="475" y="265" font-family="system-ui, sans-serif" font-size="9" fill="#1D4ED8" text-anchor="middle">4: Return List&lt;RawDetection&gt;</text>

  <!-- 5. ScanFlowProvider -> FoodRepo -->
  <line x1="395" y1="305" x2="715" y2="305" stroke="#0F172A" stroke-width="1.5" marker-end="url(#arr-sync)"/>
  <text x="555" y="300" font-family="system-ui, sans-serif" font-size="9" font-weight="600" fill="#0F172A" text-anchor="middle">5: matchWithCatalog(classes)</text>

  <!-- 6. FoodRepo -> ScanFlowProvider (Reply) -->
  <line x1="715" y1="330" x2="395" y2="330" stroke="#2563EB" stroke-width="1.5" stroke-dasharray="4 3" marker-end="url(#arr-reply)"/>
  <text x="555" y="325" font-family="system-ui, sans-serif" font-size="9" fill="#1D4ED8" text-anchor="middle">6: Return List&lt;DetectionItem&gt; (Nutrition Data)</text>

  <!-- 7. ScanFlowProvider -> ScannerScreen (Reply) -->
  <line x1="385" y1="355" x2="235" y2="355" stroke="#2563EB" stroke-width="1.5" stroke-dasharray="4 3" marker-end="url(#arr-reply)"/>
  <text x="310" y="350" font-family="system-ui, sans-serif" font-size="9" fill="#1D4ED8" text-anchor="middle">7: Render DetectionConfirmationScreen</text>

  <!-- User interaction: Review & Confirm Portions -->
  <line x1="225" y1="390" x2="95" y2="390" stroke="#0F172A" stroke-width="1.5" stroke-dasharray="4 3"/>
  <text x="160" y="385" font-family="system-ui, sans-serif" font-size="9" fill="#475569" text-anchor="middle">Show Bounding Boxes</text>

  <line x1="95" y1="420" x2="225" y2="420" stroke="#0F172A" stroke-width="1.5" marker-end="url(#arr-sync)"/>
  <text x="160" y="415" font-family="system-ui, sans-serif" font-size="9.5" font-weight="600" fill="#0F172A" text-anchor="middle">8: Confirm Grams (e.g. 150g)</text>

  <!-- Alt Block: Error Handling & Graceful Degradation -->
  <rect x="70" y="435" width="985" height="45" rx="4" fill="#FEF3C7" stroke="#F59E0B" stroke-width="1" stroke-dasharray="4 3"/>
  <text x="80" y="450" font-family="system-ui, sans-serif" font-size="9" font-weight="700" fill="#92400E">[alt: Confidence &lt; 0.30 or Wrong Detection]</text>
  <text x="80" y="465" font-family="system-ui, sans-serif" font-size="8.5" fill="#78350F">User taps "Koreksi Makanan" ➔ Opens FoodSearchModal ➔ Queries seed_foods.json / foods catalog manually</text>

  <!-- 9. ScannerScreen -> ScanFlowProvider (Save Meal) -->
  <line x1="235" y1="495" x2="385" y2="495" stroke="#0F172A" stroke-width="1.5" marker-end="url(#arr-sync)"/>
  <text x="310" y="490" font-family="system-ui, sans-serif" font-size="9.5" font-weight="600" fill="#0F172A" text-anchor="middle">9: saveMeal(type, date, items)</text>

  <!-- 10. ScanFlowProvider -> MealRepo -->
  <line x1="395" y1="525" x2="865" y2="525" stroke="#0F172A" stroke-width="1.5" marker-end="url(#arr-sync)"/>
  <text x="630" y="520" font-family="system-ui, sans-serif" font-size="9.5" font-weight="600" fill="#0F172A" text-anchor="middle">10: createMeal(mealRecord)</text>

  <!-- 11. MealRepo -> Firestore -->
  <line x1="875" y1="545" x2="1000" y2="545" stroke="#0F172A" stroke-width="1.5" marker-end="url(#arr-sync)"/>
  <text x="935" y="540" font-family="system-ui, sans-serif" font-size="9" font-weight="600" fill="#065F46" text-anchor="middle">11: set(users/{{uid}}/meals/{{id}})</text>

  <!-- 12. Firestore -> MealRepo (Reply: Sync or Cached) -->
  <line x1="1000" y1="585" x2="875" y2="585" stroke="#2563EB" stroke-width="1.5" stroke-dasharray="4 3" marker-end="url(#arr-reply)"/>
  <text x="935" y="580" font-family="system-ui, sans-serif" font-size="9" fill="#1D4ED8" text-anchor="middle">12: Success (Sync / Bounded Cache)</text>

  <!-- 13. MealRepo -> ScanFlowProvider -->
  <line x1="865" y1="610" x2="395" y2="610" stroke="#2563EB" stroke-width="1.5" stroke-dasharray="4 3" marker-end="url(#arr-reply)"/>
  <text x="630" y="605" font-family="system-ui, sans-serif" font-size="9" fill="#1D4ED8" text-anchor="middle">13: Return MealRecord DTO</text>

  <!-- 14. ScanFlowProvider -> ScannerScreen / Dashboard -->
  <line x1="385" y1="635" x2="235" y2="635" stroke="#2563EB" stroke-width="1.5" stroke-dasharray="4 3" marker-end="url(#arr-reply)"/>
  <text x="310" y="630" font-family="system-ui, sans-serif" font-size="9" fill="#1D4ED8" text-anchor="middle">14: Push MealResult &amp; Refresh Dashboard</text>
</svg>"""
    svg_path = os.path.join(OUTPUT_DIR, "fig20_scan_sequence.svg")
    png_path = os.path.join(OUTPUT_DIR, "fig20_scan_sequence.png")
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(svg)
    render_svg_to_png(svg_path, png_path, w, h)


if __name__ == "__main__":
    print("Generating all redesigned NutriView BRD diagrams...")
    generate_system_architecture()
    generate_deployment_architecture()
    generate_use_case_diagram()
    generate_navigation_flow()
    generate_activity_diagram()
    generate_database_erd()
    generate_token_flow()
    generate_database_schema_tree()
    generate_security_rules_flow()
    generate_offline_storage_flow()
    generate_scan_sequence()
    print("All diagrams generated successfully!")
