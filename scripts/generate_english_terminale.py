from json import dump, loads
from pathlib import Path
import shutil
import subprocess

BASE = Path(r"C:\EduQuest\COURS\cours-production\anglais")
DATA = loads((BASE / "catalog.json").read_text(encoding="utf-8"))
DEFAULT_SOURCE_PDF = "programme_officiel_anglais_terminale_2024.pdf"
DEFAULT_LIMITATIONS = [
    "No official Togolese annals were attached during this production pass, so exam-style tasks were calibrated from the programme and the expected classroom level.",
    "Video curation stays empty until a separate quality-controlled selection is validated.",
]
PDFLATEX = next(
    (str(p) for p in [
        Path(r"C:\texlive\2025\bin\windows\pdflatex.exe"),
        Path(r"C:\Program Files\MiKTeX\miktex\bin\x64\pdflatex.exe"),
    ] if p.exists()),
    shutil.which("pdflatex"),
)


def esc(text):
    for a, b in [("\\", "\\textbackslash{}"), ("&", "\\&"), ("%", "\\%"), ("$", "\\$"), ("#", "\\#"), ("_", "\\_"), ("{", "\\{"), ("}", "\\}"), ("~", "\\textasciitilde{}"), ("^", "\\textasciicircum{}")]:
        text = text.replace(a, b)
    return text


def blocks(items, label, color):
    out = []
    for item in items:
        title = esc(item["heading"])
        body = esc(item["body"])
        exam = esc(item["exam_angle"])
        out.append(
            f"\\subsection*{{{title}}}{body}\n"
            f"\\lessonbox{{{color}}}{{{label}}}{{{exam}}}"
        )
    return "\n".join(out)


def vocab_section(items):
    lines = []
    for item in items:
        lines.append(
            "\\vspace{0.25em}\\noindent"
            f"\\textbf{{{esc(item['term'])}}}. {esc(item['meaning'])} "
            f"Use it when {esc(item['use'])} "
            f"\\lessonbox{{ruachgold}}{{Example}}{{{esc(item['example'])}}}"
        )
    return "\n".join(lines)


def bullet(items):
    return "\n".join(f"\\item {esc(item)}" for item in items)


def sample_summary(ch):
    return " ".join(ch["revision_summary"])


def sample_paragraph(ch):
    idea1, idea2 = ch["revision_summary"][:2]
    idea3 = ch["revision_summary"][2] if len(ch["revision_summary"]) > 2 else ch["revision_summary"][1]
    local = ch["local_examples"][0]
    return (
        f"{idea1} {idea2} {idea3} "
        f"A clear student answer should connect these ideas to a real situation such as {local} "
        f"and finish with a balanced recommendation."
    )


def grammar_drill(ch):
    units = chapter_grammar_units(ch)
    if not units:
        model = sample_paragraph(ch)
        return [
            (f"Rewrite this idea clearly: {model}", model),
            ("Complete a sentence that keeps the same meaning as the chapter summary.", sample_summary(ch)),
            ("Write one original sentence using a key chapter idea.", model),
        ]
    examples = units[0]["examples"]
    base = examples[0]
    follow = examples[1] if len(examples) > 1 else examples[0]
    return [
        (f"Rewrite this idea with the target structure: {base}", base),
        (f"Complete a sentence that expresses the same meaning as: {follow}", follow),
        (f"Write one original sentence using the pattern {units[0]['formulas'][0].lower()}", examples[-1]),
    ]


def writing_model(ch):
    if ch.get("writing_example"):
        return ch["writing_example"]
    intro = f"{ch['title']} is an important topic for Terminale students because it affects both understanding and responsible action."
    body = sample_paragraph(ch)
    closing = f"For this reason, students should master the vocabulary, the method and the examples linked to {ch['title'].lower()}."
    return f"{intro} {body} {closing}"


def error_items(items):
    return "\n".join(
        f"\\item \\textbf{{Avoid}} {esc(item['mistake'])}. "
        f"\\textbf{{Better move:}} {esc(item['fix'])}"
        for item in items
    )


def chapter_grammar_units(ch):
    if ch.get("grammar_units"):
        return ch["grammar_units"]
    gf = ch.get("grammar_focus")
    if not gf:
        return []
    return [{
        "title": gf["title"],
        "summary": gf["summary"],
        "formulas": gf.get("patterns", []),
        "examples": gf.get("examples", []),
        "pitfall": gf.get("pitfall", ""),
    }]


def render_grammar_reference(ch):
    units = chapter_grammar_units(ch)
    if not units:
        return ""
    parts = ["\\section{Grammar rules to master}"]
    for unit in units:
        parts.append(f"\\subsection*{{{esc(unit['title'])}}}")
        parts.append(esc(unit["summary"]))
        if unit.get("formulas"):
            parts.append("\\lessonbox{ruachgold}{Formulae}{\\begin{itemize}[leftmargin=1.2em]" +
                         "".join(f"\\item {esc(x)}" for x in unit["formulas"]) +
                         "\\end{itemize}}")
        if unit.get("examples"):
            parts.append("\\lessonbox{ruachnavy}{Model examples}{\\begin{itemize}[leftmargin=1.2em]" +
                         "".join(f"\\item {esc(x)}" for x in unit["examples"]) +
                         "\\end{itemize}}")
        if unit.get("pitfall"):
            parts.append(f"\\lessonbox{{ruachgold}}{{Common pitfall}}{{{esc(unit['pitfall'])}}}")
    return "\n".join(parts)


def render_writing_reference(ch):
    units = ch.get("writing_units", [])
    if units:
        parts = ["\\section{Writing formats and model layouts}"]
        for unit in units:
            parts.append(f"\\subsection*{{{esc(unit['title'])}}}")
            parts.append(esc(unit["purpose"]))
            parts.append("\\lessonbox{ruachgold}{Formal layout}{\\begin{itemize}[leftmargin=1.2em]" +
                         "".join(f"\\item {esc(x)}" for x in unit.get("layout", [])) +
                         "\\end{itemize}}")
            parts.append("\\lessonbox{ruachnavy}{Useful opening lines}{\\begin{itemize}[leftmargin=1.2em]" +
                         "".join(f"\\item {esc(x)}" for x in unit.get("openings", [])) +
                         "\\end{itemize}}")
            if unit.get("closings"):
                parts.append("\\lessonbox{ruachgold}{Useful closing lines}{\\begin{itemize}[leftmargin=1.2em]" +
                             "".join(f"\\item {esc(x)}" for x in unit.get("closings", [])) +
                             "\\end{itemize}}")
            if unit.get("punctuation_notes"):
                parts.append("\\lessonbox{ruachnavy}{Punctuation and form}{\\begin{itemize}[leftmargin=1.2em]" +
                             "".join(f"\\item {esc(x)}" for x in unit.get("punctuation_notes", [])) +
                             "\\end{itemize}}")
            parts.append(f"\\lessonbox{{ruachgold}}{{Model excerpt}}{{{esc(unit['model_excerpt'])}}}")
        return "\n".join(parts)
    if not ch.get("writing_example"):
        return ""
    skeleton = ch.get("writing_skeleton", ch.get("writing_plan", []))
    header = ch.get("writing_format", "Model writing")
    return "\n".join([
        "\\section{Model writing answer}",
        f"\\subsection*{{{esc(header)}}}",
        esc(ch["writing_task"]),
        "\\lessonbox{ruachgold}{Reusable structure}{\\begin{itemize}[leftmargin=1.2em]" +
        "".join(f"\\item {esc(x)}" for x in skeleton) +
        "\\end{itemize}}",
        f"\\lessonbox{{ruachnavy}}{{Model answer}}{{{esc(ch['writing_example'])}}}",
    ])


def preamble(title):
    return """\\documentclass[12pt,a4paper]{article}
\\usepackage[utf8]{{inputenc}}
\\usepackage[T1]{{fontenc}}
\\usepackage[a4paper,margin=3.8cm]{{geometry}}
\\usepackage{{setspace,hyperref,xcolor,tikz,eso-pic,booktabs,listings,amsmath,caption,graphicx,enumitem,tocloft}}
\\definecolor{{ruachnavy}}{{HTML}}{{0B1F3A}}
\\definecolor{{ruachgold}}{{HTML}}{{C9A961}}
\\setstretch{{1.28}}
\\setlength{{\\parindent}}{{0pt}}
\\setlength{{\\parskip}}{{0.55em}}
\\hypersetup{{colorlinks=true,linkcolor=ruachgold,urlcolor=ruachgold}}
\\sloppy
\\emergencystretch=1em
\\newcommand{{\\lessonbox}}[3]{{\\vspace{{0.4em}}\\noindent\\fcolorbox{{#1}}{{white}}{{\\parbox{{0.94\\linewidth}}{{\\textbf{{#2}}\\\\#3}}}}\\par\\vspace{{0.45em}}}}
\\newcommand{{\\titleband}}{{\\AddToShipoutPictureBG*{{\\begin{{tikzpicture}}[remember picture,overlay]\\fill[ruachnavy] (current page.north west) rectangle ([yshift=-1.5cm]current page.north east);\\fill[ruachnavy] (current page.south west) rectangle ([yshift=0.9cm]current page.south east);\\end{{tikzpicture}}}}}}
\\newcommand{{\\pageborder}}{{\\AddToShipoutPictureBG{{\\begin{{tikzpicture}}[remember picture,overlay]\\draw[ruachnavy,line width=1.2pt] ([xshift=0.6cm,yshift=-0.6cm]current page.north west) rectangle ([xshift=-0.6cm,yshift=0.6cm]current page.south east);\\draw[ruachgold,line width=0.5pt] ([xshift=0.85cm,yshift=-0.85cm]current page.north west) rectangle ([xshift=-0.85cm,yshift=0.85cm]current page.south east);\\end{{tikzpicture}}}}}}
\\makeatletter
\\def\\ps@ruach{{\\def\\@oddhead{{\\hfill\\small\\color{{ruachnavy}} __TITLE__\\hfill}}\\let\\@evenhead\\@oddhead\\def\\@oddfoot{{\\hfil\\thepage\\hfil}}\\let\\@evenfoot\\@oddfoot}}
\\renewcommand\\section{{\\@startsection{{section}}{{1}}{{\\z@}}{{-3.2ex plus -1ex minus -.2ex}}{{2.1ex plus .2ex}}{{\\normalfont\\Large\\bfseries\\color{{ruachnavy}}}}}}
\\renewcommand\\subsection{{\\@startsection{{subsection}}{{2}}{{\\z@}}{{-2.6ex plus -1ex minus -.2ex}}{{1.2ex plus .2ex}}{{\\normalfont\\large\\bfseries\\color{{ruachnavy}}}}}}
\\makeatother
""".replace("__TITLE__", esc(title)).replace("{{", "{").replace("}}", "}")


def course_tex(ch):
    grammar_section = render_grammar_reference(ch)
    writing_section = render_writing_reference(ch)
    return preamble(ch["title"]) + f"""\\pageborder
\\titleband
\\begin{{document}}
\\pagestyle{{ruach}}
\\begin{{titlepage}}
\\thispagestyle{{empty}}
\\color{{ruachnavy}}
\\vspace*{{2.2cm}}
\\begin{{center}}
{{\\Large\\bfseries RuachEdu English Revision Sheet}}\\\\[0.4em]
{{\\large\\bfseries {esc(ch["title"])}}}\\\\[0.2em]
{{Terminale {" / ".join(ch["series"])} \\quad Theme: {esc(ch["theme"])}}}
\\end{{center}}
\\vfill
\\begin{{center}}
\\textcolor{{ruachgold}}{{\\rule{{0.42\\linewidth}}{{0.8pt}}}}\\\\[0.6em]
\\small Smart revision sheet for Terminale English.
\\end{{center}}
\\end{{titlepage}}
\\color{{black}}
\\tableofcontents
\\newpage

\\section{{Learning goals}}
This sheet is meant for revision, not for passive reading. After studying it, a student should be able to explain the topic, reuse the key vocabulary, and answer school tasks with clear English.
\\begin{{itemize}}[leftmargin=1.2em]
{bullet(ch["learning_goals"])}
\\end{{itemize}}

\\section{{Core lesson}}
{esc(ch["overview"])}
\\lessonbox{{ruachgold}}{{What an examiner expects}}{{A strong Terminale answer defines the topic clearly, develops two or three organised ideas, supports them with a concrete example, and ends with a balanced conclusion.}}

\\section{{Ideas that really matter}}
{blocks(ch["core_ideas"], "Exam move", "ruachnavy")}

\\section{{Vocabulary to understand and reuse}}
Do not memorise these words as isolated labels. Learn what they mean, when to use them, and how they help you build a better answer.
{vocab_section(ch["vocabulary"])}

{grammar_section}

\\section{{Speaking and oral response}}
\\subsection*{{Speaking task}}
{esc(ch["speaking_task"])}
\\begin{{itemize}}[leftmargin=1.2em]
{bullet(ch["speaking_plan"])}
\\end{{itemize}}
\\lessonbox{{ruachgold}}{{Local angle}}{{{esc(" and ".join(ch["local_examples"]))}. A good answer becomes stronger when it connects the lesson to lived situations instead of staying abstract.}}

{writing_section}

\\section{{Frequent mistakes}}
\\begin{{itemize}}[leftmargin=1.2em]
{error_items(ch["frequent_errors"])}
\\end{{itemize}}

\\section{{Mini revision summary}}
\\begin{{itemize}}[leftmargin=1.2em]
{bullet(ch["revision_summary"])}
\\end{{itemize}}
\\end{{document}}
"""


def exercises_tex(ch):
    vocab = ", ".join(item["term"] for item in ch["vocabulary"][:6])
    grammar_units = chapter_grammar_units(ch)
    pattern = grammar_units[0]["formulas"][0] if grammar_units and grammar_units[0].get("formulas") else "Review the model structures in the lesson."
    vocab_models = "\n".join(
        f"\\item \\textbf{{{esc(item['term'])}}}: {esc(item['example'])}"
        for item in ch["vocabulary"][:4]
    )
    summary_model = sample_summary(ch)
    grammar_models = "\n".join(
        f"\\item \\textbf{{Prompt}}: {esc(prompt)}\\\\ \\textbf{{Model answer}}: {esc(answer)}"
        for prompt, answer in grammar_drill(ch)
    )
    writing_sample = writing_model(ch)
    exam_sample = sample_paragraph(ch)
    return preamble(f"Exercises - {ch['title']}") + f"""\\pageborder
\\begin{{document}}
\\pagestyle{{ruach}}
\\begin{{center}}
{{\\Large\\bfseries RuachEdu Exercise Set}}\\\\[0.3em]
{{\\large\\bfseries {esc(ch["title"])}}}\\\\[0.2em]
{{Terminale {" / ".join(ch["series"])}}}
\\end{{center}}
\\thispagestyle{{empty}}

\\section*{{Solved vocabulary examples}}
Key words from this chapter: {esc(vocab)}.
\\lessonbox{{ruachgold}}{{Model sentences}}{{These examples show how the chapter vocabulary should appear in a real exam answer.}}
\\begin{{itemize}}[leftmargin=1.2em]
{vocab_models}
\\end{{itemize}}

\\section*{{Solved summary example}}
\\lessonbox{{ruachnavy}}{{Model answer}}{{{esc(summary_model)}}}

\\section*{{Solved grammar examples}}
\\lessonbox{{ruachgold}}{{Target formula}}{{{esc(pattern)}}}
\\begin{{itemize}}[leftmargin=1.2em]
{grammar_models}
\\end{{itemize}}

\\section*{{Solved writing model}}
\\lessonbox{{ruachnavy}}{{Model answer}}{{{esc(writing_sample)}}}

\\section*{{Solved exam-style response}}
\\lessonbox{{ruachgold}}{{Model answer}}{{{esc(exam_sample)}}}
\\end{{document}}
"""


def text_expl(value):
    return [{"type": "text", "value": value}]


def single(qid, prompt, options, answer, explanation):
    return {"id": qid, "type": "single_choice", "prompt": prompt, "answer_key": {"options": options, "answer": answer}, "explanation": text_expl(explanation), "points": 1}


def multi(qid, prompt, options, answers, explanation):
    return {"id": qid, "type": "multi_choice", "prompt": prompt, "answer_key": {"options": options, "answers": answers}, "explanation": text_expl(explanation), "points": 1}


def fill(qid, text, answer, explanation):
    return {"id": qid, "type": "fill_blank", "prompt": "Complete the gap with the best word or expression.", "answer_key": {"text": text, "blanks": [{"position": 1, "answer": answer}]}, "explanation": text_expl(explanation), "points": 1}


def matching(qid, pairs, explanation):
    left = [{"id": f"l{i}", "label": k} for i, (k, _) in enumerate(pairs, 1)]
    right = [{"id": f"r{i}", "label": v} for i, (_, v) in enumerate(pairs, 1)]
    correct = {item["id"]: right[i]["id"] for i, item in enumerate(left)}
    return {"id": qid, "type": "matching", "prompt": "Match each item on the left with the best answer on the right.", "answer_key": {"left_items": left, "right_items": right, "correct_pairs": correct}, "explanation": text_expl(explanation), "points": 2}


def vocab_blank(item):
    return item["example"].replace(item["term"], "___", 1)


def quiz_defs(ch):
    vocab = ch["vocabulary"]
    ideas = ch["revision_summary"]
    errs = ch["frequent_errors"]
    grammar_units = chapter_grammar_units(ch)
    grammar = grammar_units[0] if grammar_units else {
        "title": "Useful language support",
        "formulas": ["Review the key model sentences from the lesson."],
        "examples": [sample_paragraph(ch), sample_summary(ch)],
        "pitfall": "Avoid copying expressions without understanding the meaning.",
    }
    title = ch["title"]
    wp = ch["writing_plan"]
    sp = ch["speaking_plan"]
    wp_mid = wp[min(2, len(wp) - 1)]
    wp_end = wp[-1]
    sp_start = sp[0]
    sp_mid = sp[min(1, len(sp) - 1)]
    sp_next = sp[min(2, len(sp) - 1)]
    files = [
        ("quiz-01-core.json", f"Quick Check - {title}", {"mode": "standard", "time_per_question_seconds": 45, "shuffle_options": True, "show_feedback": True, "allow_go_back": True, "editable_until_next": True, "passing_score_percent": 60}),
        ("quiz-02-vocabulary.json", f"Vocabulary Builder - {title}", {"mode": "standard", "time_per_question_seconds": 50, "shuffle_options": True, "show_feedback": True, "allow_go_back": True, "editable_until_next": True, "partial_credit": True, "passing_score_percent": 60}),
        ("quiz-03-language.json", f"Language and Writing - {title}", {"mode": "standard", "time_per_question_seconds": 55, "shuffle_options": True, "show_feedback": True, "allow_go_back": True, "editable_until_next": True, "partial_credit": True, "passing_score_percent": 65}),
        ("quiz-04-exam-prep.json", f"Exam Prep - {title}", {"mode": "standard", "time_per_question_seconds": 60, "shuffle_options": True, "show_feedback": False, "feedback_mode": "after_submit", "allow_go_back": True, "editable_until_next": True, "passing_score_percent": 70}),
    ]
    sets = []
    q1 = [
        single(f"{ch['slug']}-core-1", f"What is the main focus of the chapter \"{title}\"?", [ch["learning_goals"][0], "learning random isolated words only", "studying a different school subject", "describing a topic without explanation"], ch["learning_goals"][0], "The first learning goal states the main focus clearly."),
        single(f"{ch['slug']}-core-2", "Which statement best captures a key idea from the lesson?", [ideas[0], "Only experts should discuss the topic.", errs[0]["mistake"], "The topic has no practical consequence."], ideas[0], "This revision point belongs to the chapter summary."),
        single(f"{ch['slug']}-core-3", "Which statement is also part of the lesson?", [ideas[1], "Memorisation alone is enough.", "No example is ever needed.", "The issue cannot be discussed at school."], ideas[1], "Good revision starts from the real lesson ideas."),
        multi(f"{ch['slug']}-core-4", "Select the points that belong to the chapter.", [ideas[2], ideas[3], "The topic should never be analysed.", "Evidence is useless in a school answer."], [ideas[2], ideas[3]], "Both selected statements come from the revision summary."),
        fill(f"{ch['slug']}-core-5", vocab_blank(vocab[0]), vocab[0]["term"], "The missing word is a key chapter term."),
        fill(f"{ch['slug']}-core-6", vocab_blank(vocab[1]), vocab[1]["term"], "This word is used in the example sentence."),
        matching(f"{ch['slug']}-core-7", [(v["term"], v["meaning"]) for v in vocab[:4]], "Match the term to its meaning, not to a random context."),
        single(f"{ch['slug']}-core-8", "Which mistake must you avoid?", [errs[0]["mistake"], "using a clear example", "defining the topic first", "organising ideas logically"], errs[0]["mistake"], "The lesson explicitly warns against this trap."),
        multi(f"{ch['slug']}-core-9", "What usually strengthens a Terminale answer?", [wp[0], wp_mid, "copying the title only", "ignoring local examples"], [wp[0], wp_mid], "A good answer needs structure and support."),
        single(f"{ch['slug']}-core-10", "What should a student do in speaking?", [sp_start, "list words without building ideas", "jump to the conclusion immediately", "avoid all examples"], sp_start, "The speaking plan begins with this move."),
    ]
    q2 = [
        matching(f"{ch['slug']}-voc-1", [(v["term"], v["meaning"]) for v in vocab[4:8]], "Vocabulary is easier to retain when term and meaning stay linked."),
        fill(f"{ch['slug']}-voc-2", vocab_blank(vocab[2]), vocab[2]["term"], "This chapter word completes the sentence."),
        fill(f"{ch['slug']}-voc-3", vocab_blank(vocab[3]), vocab[3]["term"], "This example was built to teach the term in context."),
        single(f"{ch['slug']}-voc-4", f"When should you use the word \"{vocab[4]['term']}\"?", [vocab[4]["use"], "when naming a cooking tool", "when describing a football score", "when talking about weather only"], vocab[4]["use"], "Use depends on context, not on memorisation alone."),
        single(f"{ch['slug']}-voc-5", f"What does \"{vocab[5]['term']}\" mean in this chapter?", [vocab[5]["meaning"], "a private joke", "a colour used in art", "a school uniform"], vocab[5]["meaning"], "The vocabulary note gives the meaning directly."),
        multi(f"{ch['slug']}-voc-6", "Choose the words that really belong to the lesson vocabulary.", [vocab[6]["term"], vocab[7]["term"], "microscope", "stadium"], [vocab[6]["term"], vocab[7]["term"]], "Both chosen items come from the chapter glossary."),
        single(f"{ch['slug']}-voc-7", "Why is vocabulary important in this chapter?", ["It helps students build accurate and convincing answers.", "It replaces all reasoning.", "It is only for decoration.", "It matters only in oral tasks."], "It helps students build accurate and convincing answers.", "Precise vocabulary improves both understanding and expression."),
        fill(f"{ch['slug']}-voc-8", f"A good student does not learn {vocab[0]['term']} in isolation; the word must be used in a real ___.", "context", "Vocabulary becomes useful when it is tied to context."),
        single(f"{ch['slug']}-voc-9", "Which action improves vocabulary retention?", ["reusing words in sentences and short answers", "memorising a list without meaning", "avoiding examples completely", "changing the topic every sentence"], "reusing words in sentences and short answers", "Active reuse is the best revision strategy."),
        multi(f"{ch['slug']}-voc-10", "Choose the best habits for this vocabulary quiz.", ["link term, meaning and example", "reuse words in writing", "ignore chapter context", "learn false meanings"], ["link term, meaning and example", "reuse words in writing"], "Good habits combine meaning, use and practice."),
    ]
    q3 = [
        single(f"{ch['slug']}-lang-1", "What is the language focus of this chapter?", [grammar["title"], "pure translation without structure", "poetry analysis only", "mathematical notation"], grammar["title"], "The grammar section names the focus explicitly."),
        single(f"{ch['slug']}-lang-2", "Which pattern belongs to the chapter?", [grammar["formulas"][0], "noun + of + noun only", "random abbreviations", "silent reading without language work"], grammar["formulas"][0], "This is one of the chapter patterns."),
        single(f"{ch['slug']}-lang-3", "Which sentence model fits the lesson?", [grammar["examples"][0], "Rain has been because of clearly.", "Students should to write fast.", "Topic example without grammar."], grammar["examples"][0], "Model sentences show the right structure in use."),
        multi(f"{ch['slug']}-lang-4", "Which actions improve the writing task?", [wp[min(1, len(wp) - 1)], wp[min(3, len(wp) - 1)], "skip the conclusion", "avoid chapter vocabulary"], [wp[min(1, len(wp) - 1)], wp[min(3, len(wp) - 1)]], "The writing plan guides method and organisation."),
        multi(f"{ch['slug']}-lang-5", "What should appear in a solid speaking answer?", [sp_mid, sp_next, "empty repetition", "a conclusion with no argument"], [sp_mid, sp_next], "Speaking needs explanation, not scattered ideas."),
        fill(f"{ch['slug']}-lang-6", f"{grammar['examples'][1].replace(grammar['examples'][1].split()[1], '___', 1)}", grammar["examples"][1].split()[1], "The hidden word comes from the model sentence."),
        single(f"{ch['slug']}-lang-7", "Which pitfall is mentioned in the lesson?", [grammar["pitfall"], "always write the longest sentence possible", "never organise ideas", "avoid all connectors"], grammar["pitfall"], "The lesson warns students against this misuse."),
        fill(f"{ch['slug']}-lang-8", "A useful written answer needs a clear introduction, development and short ___.", "conclusion", "The writing method ends with a conclusion."),
        single(f"{ch['slug']}-lang-9", "What is the role of the writing plan?", ["It helps students organise ideas before they write.", "It replaces grammar completely.", "It is only for teachers.", "It prevents examples."], "It helps students organise ideas before they write.", "Planning improves coherence."),
        multi(f"{ch['slug']}-lang-10", "Choose the statements that match RuachEdu method.", ["Define the topic before arguing.", "Support an idea with an example.", "Give opinions without reasons.", "Ignore the exact task."], ["Define the topic before arguing.", "Support an idea with an example."], "Method matters as much as vocabulary."),
    ]
    q4 = [
        single(f"{ch['slug']}-exam-1", "What is the safest first move in an exam answer?", [sp_start, "copy the question and stop", "jump to a slogan", "write disconnected examples"], sp_start, "Start by defining or framing the issue clearly."),
        multi(f"{ch['slug']}-exam-2", "Which features make an answer convincing?", [wp_mid, wp_end, "no clear structure", "no conclusion"], [wp_mid, wp_end], "Examples and a controlled ending strengthen the answer."),
        single(f"{ch['slug']}-exam-3", "Which local angle could strengthen the chapter?", [ch["local_examples"][0], "an unrelated sports result", "a random celebrity name", "a science formula with no link"], ch["local_examples"][0], "Local situations make the answer concrete."),
        single(f"{ch['slug']}-exam-4", "Which of these should be avoided in an exam-style answer?", [errs[1]["mistake"], "using one relevant example", "linking causes and effects", "staying on topic"], errs[1]["mistake"], "This is one of the frequent errors listed in the sheet."),
        fill(f"{ch['slug']}-exam-5", "A balanced answer should analyse causes, effects and realistic ___.", "responses", "The lesson insists on realistic responses, not empty slogans."),
        fill(f"{ch['slug']}-exam-6", "When official annals are missing, the lesson still aims at an exam-style ___ task.", "training", "The exercises remain exam-oriented even with that limitation."),
        matching(f"{ch['slug']}-exam-7", [("Definition", "state what the topic means"), ("Argument", "develop a clear idea with support"), ("Example", "connect the idea to a concrete situation"), ("Conclusion", "close with a balanced final sentence")], "These are the building blocks of a solid answer."),
        multi(f"{ch['slug']}-exam-8", "Select the responsible revision habits.", ["review vocabulary with examples", "practise short organised answers", "memorise blindly without understanding", "ignore common mistakes"], ["review vocabulary with examples", "practise short organised answers"], "Revision is stronger when it mixes understanding and practice."),
        single(f"{ch['slug']}-exam-9", "Why does the sheet include frequent mistakes?", ["To prevent predictable weaknesses in student answers.", "To make the chapter longer.", "To replace the core lesson.", "To avoid all writing tasks."], "To prevent predictable weaknesses in student answers.", "Knowing the traps saves points."),
        single(f"{ch['slug']}-exam-10", "What should remain visible from start to finish?", ["the exact question being answered", "only the student's emotions", "a list of unrelated words", "a copied definition with no development"], "the exact question being answered", "Strong answers stay faithful to the task."),
    ]
    for (filename, quiz_title, config), questions in zip(files, [q1, q2, q3, q4]):
        sets.append((filename, {"version": 2, "quiz": {"id": f"{ch['slug']}-{filename[:-5]}", "title": quiz_title, "config": config, "questions": questions}}))
    return sets


def meta(ch):
    return {
        "slug": ch["slug"],
        "title": ch["title"],
        "subject_code": "ANGL",
        "level_label": "Terminale",
        "series_codes": ch["series"],
        "source_pdf": ch.get("source_pdf", DEFAULT_SOURCE_PDF),
        "source_pages": ch["source_pages"],
        "publication_version": "v1",
        "content_kind": ch.get("content_kind", "revision_sheet"),
        "limitations": ch.get("limitations", DEFAULT_LIMITATIONS),
    }


def compile_tex(tex_path, jobname):
    if not PDFLATEX:
        raise RuntimeError("pdflatex not found")
    for _ in range(2):
        subprocess.run(
            [PDFLATEX, "-interaction=nonstopmode", "-halt-on-error", f"-jobname={jobname}", tex_path.name],
            cwd=tex_path.parent,
            check=True,
            capture_output=True,
            text=True,
        )


for ch in DATA:
    chapter = BASE / ch["slug"]
    chapter.mkdir(parents=True, exist_ok=True)
    (chapter / "cours.tex").write_text(course_tex(ch), encoding="utf-8")
    (chapter / "exercices.tex").write_text(exercises_tex(ch), encoding="utf-8")
    dump({"videos": ch.get("videos", [])}, (chapter / "videos.json").open("w", encoding="utf-8"), indent=2, ensure_ascii=False)
    dump(meta(ch), (chapter / "meta.json").open("w", encoding="utf-8"), indent=2, ensure_ascii=False)
    legacy_quiz = chapter / "quiz.json"
    if legacy_quiz.exists():
        legacy_quiz.unlink()
    for filename, quiz in quiz_defs(ch):
        dump(quiz, (chapter / filename).open("w", encoding="utf-8"), indent=2, ensure_ascii=False)
    compile_tex(chapter / "cours.tex", "course-v1")
    compile_tex(chapter / "exercices.tex", "exercise-set-v1")

print(f"generated {len(DATA)} rich English chapter folders")
