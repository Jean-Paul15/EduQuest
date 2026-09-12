from pypdf import PdfReader
pdf = PdfReader(r"C:\EduQuest\COURS\770195913-M-KATO-ANG-Tle-2024.pdf")
keys = [
  'democracy in the usa','different political regimes','women role in entrepreneurship',
  'global warming','farming in modern society','e-commerce in africa','e-learning in the world',
  'respect of state property','patriotic acts','land issues','traditional arts in togo',
  'violent extremism','renewable energies','artificial intelligence and modern society','phytotherapy and health'
]
for i, page in enumerate(pdf.pages, start=1):
    text = (page.extract_text() or '').replace('\r', ' ')
    low = text.lower()
    if any(k in low for k in keys):
        print(f'--- PAGE {i} ---')
        print(text[:2500])
        print()
