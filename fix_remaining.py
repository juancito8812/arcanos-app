#!/usr/bin/env python3
"""Fix remaining Flutter analysis errors."""
import os

BASE = r"C:/Users/Juan Sanchez/Desktop/mis proyectos de programacion/aplicacion arcanos mayores"

def fix_tarot_menu():
    path = os.path.join(BASE, "lib/screens/tarot/tarot_menu_screen.dart")
    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()
    # Remove line 31 (index 30) - extra closing brackets
    fixed = lines[:30] + lines[31:]
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(fixed)
    print(f"[OK] tarot_menu_screen.dart: removed line 31, now {len(fixed)} lines")

def fix_constellation():
    path = os.path.join(BASE, "lib/screens/constellations/constellation_screen.dart")
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Find where the _Secretos build method's return starts
    sc_start = content.find("SingleChildScrollView(padding: const EdgeInsets.all(16),")
    if sc_start < 0:
        # Try to find the truncated version
        sc_start = content.find("SingleChildScrollView")
    
    if sc_start >= 0:
        # Truncate everything from sc_start and complete the class
        head = content[:content.rfind("\n", 0, sc_start) + 1] if sc_start > 0 else ""
        
        # Find the indentation from the return statement
        indent = "      "
        
        completed = f'''{indent}return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
{indent}  Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
{indent}    const Text('Los hijos reproducen los secretos familiares:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
{indent}    const SizedBox(height: 12),
{indent}    _Secret('- Primogenito: Padre', 'El primero hereda la lealtad del padre.'),
{indent}    _Secret('- Segundo: Madre', 'El segundo carga la balanza con la madre.'),
{indent}    _Secret('- Tercero: Matrimonio', 'El tercero busca el equilibrio en la pareja.'),
{indent}    _Secret('- Cuarto: Familia', 'El cuarto restaura el orden del sistema.'),
{indent}  ]))),
{indent}]));
  }}
}}

class _Secret extends StatelessWidget {{
  final String title;
  final String desc;
  const _Secret(this.title, this.desc);
  @override
  Widget build(BuildContext context) {{
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.purplePrimary)),
      const SizedBox(height: 4),
      Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
    ]));
  }}
}}
'''
        # Find the beginning of the _Secretos class
        class_start = content.rfind("class _Secretos", 0, sc_start)
        if class_start >= 0:
            # Keep everything from the beginning up to the class definition start,
            # then write the class with the completed content
            prefix = content[:class_start]
            # Add the _Secretos class with correct content
            result = prefix + '''class _Secretos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
''' + completed[len(indent):]
            with open(path, "w", encoding="utf-8") as f:
                f.write(result)
            print(f"[OK] constellation_screen.dart: completed _Secretos class")
        else:
            print(f"[ERR] Could not find _Secretos class start")
    else:
        print(f"[INFO] constellation_screen.dart: SingleChildScrollView not found, checking file")
        print(content[-100:])

def check_settings():
    path = os.path.join(BASE, "lib/screens/settings/settings_screen.dart")
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    if "Bienestar Integral y Crecimiento Personal" in content:
        print(f"[OK] settings_screen.dart: credits string looks correct")
    else:
        print(f"[WARN] settings_screen.dart: may need checking")
        print(content[-200:])

if __name__ == "__main__":
    fix_tarot_menu()
    fix_constellation()
    check_settings()
    print("\nDone!")
