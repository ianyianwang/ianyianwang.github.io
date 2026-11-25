# encoding: utf-8
Encoding.default_external = Encoding::UTF_8
# Builds the Phonics Hub pages from _build/pages/*.html into ../
# Run:  ruby phonics/_build/build.rb      (from the repo folder)
# Each page file = the <main> content only. Header, step bar, pager and footer come from here,
# so every page looks and works the same.

DIR  = File.expand_path(__dir__)
OUT  = File.expand_path('..', DIR)
BASE = 'https://ianyianwang.github.io/phonics/'

PAGES = [
  { file: 'index.html',   step: nil, nav: 'Home',             title: 'Phonics Hub' },
  { file: 'reading.html', step: 1,   nav: 'Why read',         title: 'Why reading matters' },
  { file: 'phonics.html', step: 2,   nav: 'How phonics works', title: 'How phonics works' },
  { file: 'sounds.html',  step: 3,   nav: 'The sounds',       title: 'The sounds' },
  { file: 'groups.html',  step: 4,   nav: 'Reading groups',   title: 'Reading groups' },
  { file: 'home.html',    step: 5,   nav: 'Help at home',     title: 'Help at home' },
]

def translate_url(file, lang)
  path = file == 'index.html' ? '' : file
  "https://ianyianwang-github-io.translate.goog/phonics/#{path}?_x_tr_sl=en&_x_tr_tl=#{lang}&_x_tr_hl=#{lang}"
end

def step_bar(current)
  items = PAGES.map do |p|
    num = p[:step] ? p[:step].to_s : '⌂'
    cur = p[:file] == current ? ' aria-current="page"' : ''
    href = p[:file] == 'index.html' ? './' : p[:file]
    %(<li><a href="#{href}"#{cur}><span class="num">#{num}</span>#{p[:nav]}</a></li>)
  end
  %(<nav class="steps" aria-label="Pages"><ol>#{items.join}</ol></nav>)
end

def pager(i)
  prev_p = i > 0 ? PAGES[i - 1] : nil
  next_p = PAGES[i + 1]
  href = ->(p) { p[:file] == 'index.html' ? './' : p[:file] }
  label = ->(p) { p[:step] ? "Step #{p[:step]}: #{p[:title]}" : 'Home' }
  out = +'<nav class="pager" aria-label="Previous and next">'
  out << %(<a href="#{href.(prev_p)}"><small>← Back</small><b>#{label.(prev_p)}</b></a>) if prev_p
  out << %(<a class="next" href="#{href.(next_p)}"><small>Next →</small><b>#{label.(next_p)}</b></a>) if next_p
  out << %(<a class="next" href="./"><small>Finished!</small><b>Back to the start</b></a>) unless next_p
  out << '</nav>'
end

PAGES.each_with_index do |p, i|
  body = File.read(File.join(DIR, 'pages', p[:file]), encoding: 'UTF-8')
  page_title = p[:file] == 'index.html' ? 'SBS Bangkok Phonics Hub' : "#{p[:title]} · SBS Bangkok Phonics Hub"
  html = <<~HTML
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <meta name="robots" content="noindex">
      <title>#{page_title}</title>
      <meta name="description" content="A simple guide for SBS Bangkok parents: how your child learns to read with Read Write Inc. Phonics, and how you can help at home.">
      <link rel="preconnect" href="https://fonts.googleapis.com">
      <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
      <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@400;600;700&display=swap" rel="stylesheet">
      <link rel="stylesheet" href="phonics.css?v=1">
    </head>
    <body>
    <a class="skip" href="#main">Skip to content</a>
    <header class="top">
      <div class="wrap">
        <a class="brand" href="./">
          <span class="brand-mark" aria-hidden="true">Aa</span>
          <span class="brand-text"><b>Phonics Hub</b><small>SBS Bangkok · for parents</small></span>
        </a>
        <div class="lang" aria-label="Read this page in another language">
          <a href="#{translate_url(p[:file], 'th')}" lang="th">ภาษาไทย</a>
          <a href="#{translate_url(p[:file], 'zh-CN')}" lang="zh">中文</a>
        </div>
      </div>
    </header>
    #{step_bar(p[:file])}
    <main id="main">
    #{body.strip}
    <div class="wrap">#{pager(i)}</div>
    </main>
    <footer>
      <div class="wrap">
        <div><b>Questions about phonics?</b>Please talk to your child's class teacher. <span class="todo">Add the name and email of the SBS phonics lead here.</span></div>
        <div><b>About this guide</b>Our school teaches reading with Read Write Inc. Phonics by Ruth Miskin. Videos and sheets on this site link to the official Ruth Miskin and Oxford websites.</div>
      </div>
    </footer>
    <script>
      // On phones, scroll the step bar so the current page is visible.
      const cur = document.querySelector('.steps a[aria-current]');
      if (cur) cur.parentElement.parentElement.scrollLeft = cur.offsetLeft - 20;
      // Draft mode: add ?draft to any page address to see the red "to add / check" notes.
      if (/[?&]draft/.test(location.search)) {
        document.body.classList.add('draft');
        document.querySelectorAll('a[href]').forEach(a => {
          const h = a.getAttribute('href');
          if (h && !/^(https?:|#|mailto:)/.test(h)) a.setAttribute('href', h.replace(/(#.*)?$/, '?draft$1'));
        });
      }
    </script>
    </body>
    </html>
  HTML
  File.write(File.join(OUT, p[:file]), html, encoding: 'UTF-8')
  puts "built #{p[:file]}"
end
