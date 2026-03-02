#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use open qw(:std :encoding(UTF-8));

if (@ARGV < 3 || @ARGV > 7) {
    die "Usage: render-handbook-md.pl <input.md> <output.html> <lang> [root_prefix] [screenshots_href] [index_href] [doc_link_prefix]\n";
}

my ($input_path, $output_path, $lang, $root_prefix, $screenshots_href, $index_href, $doc_link_prefix) = @ARGV;
$root_prefix = defined($root_prefix) ? $root_prefix : '../../';
$screenshots_href = defined($screenshots_href) ? $screenshots_href : './screenshots.html';
$index_href = defined($index_href) ? $index_href : './index.html';
our $DOC_LINK_PREFIX = defined($doc_link_prefix) ? $doc_link_prefix : '';

open my $in_fh, '<', $input_path or die "Cannot open $input_path: $!";
my @lines = <$in_fh>;
close $in_fh;

sub escape_html {
    my ($s) = @_;
    $s =~ s/&/&amp;/g;
    $s =~ s/</&lt;/g;
    $s =~ s/>/&gt;/g;
    return $s;
}

sub normalize_url {
    my ($url) = @_;
    $url =~ s/^\s+|\s+$//g;
    $url =~ s/\.md$/.html/;
    if ($DOC_LINK_PREFIX ne ''
        && $url !~ m{^(?:/|#|https?://|mailto:|javascript:)}
        && $url !~ m{^\.\./}) {
        $url =~ s{^\./}{};
        $url = $DOC_LINK_PREFIX . $url;
    }
    return $url;
}

sub inline_markdown {
    my ($text) = @_;
    $text = escape_html($text);

    # Images first to avoid link replacement conflicts.
    $text =~ s{!\[([^\]]*)\]\(([^)]+)\)}{
        my $alt = escape_html($1);
        my $src = normalize_url($2);
        qq{<img src="$src" alt="$alt" loading="lazy" />};
    }ge;

    $text =~ s{\[([^\]]+)\]\(([^)]+)\)}{
        my $label = $1;
        my $href = normalize_url($2);
        qq{<a href="$href">$label</a>};
    }ge;

    $text =~ s{`([^`]+)`}{<code>$1</code>}g;
    return $text;
}

sub slugify {
    my ($s) = @_;
    $s = lc($s);
    $s =~ s/ä/ae/g;
    $s =~ s/ö/oe/g;
    $s =~ s/ü/ue/g;
    $s =~ s/ß/ss/g;
    $s =~ s/[`'’]//g;
    $s =~ s/[^\p{L}\p{N}]+/-/g;
    $s =~ s/^-+//;
    $s =~ s/-+$//;
    return $s || 'section';
}

my @language_options = (
    { code => 'en',      label => '🇺🇸 English',   href => $root_prefix . 'en/manual/index.html',      home_label => 'Manual',      default_title => 'Gymmix Manual' },
    { code => 'de',      label => '🇩🇪 Deutsch',   href => $root_prefix . 'de/handbuch/index.html',    home_label => 'Handbuch',    default_title => 'Gymmix Handbuch' },
    { code => 'zh-hans', label => '🇨🇳 简体中文',   href => $root_prefix . 'zh-hans/manual/index.html', home_label => '手册',        default_title => 'Gymmix 手册' },
    { code => 'vi',      label => '🇻🇳 Tiếng Việt', href => $root_prefix . 'vi/manual/index.html',    home_label => 'Sổ tay',      default_title => 'Sổ tay Gymmix' },
    { code => 'fr',      label => '🇫🇷 Français',  href => $root_prefix . 'fr/manual/index.html',      home_label => 'Manuel',      default_title => 'Manuel Gymmix' },
    { code => 'es',      label => '🇪🇸 Español',   href => $root_prefix . 'es/manual/index.html',      home_label => 'Manual',      default_title => 'Manual de Gymmix' },
    { code => 'hi',      label => '🇮🇳 हिन्दी',    href => $root_prefix . 'hi/manual/index.html',      home_label => 'मैनुअल',      default_title => 'Gymmix मैनुअल' },
    { code => 'pt-pt',   label => '🇵🇹 Português (Portugal)', href => $root_prefix . 'pt-pt/manual/index.html', home_label => 'Manual', default_title => 'Manual Gymmix' },
    { code => 'pt-br',   label => '🇧🇷 Português (Brasil)',   href => $root_prefix . 'pt-br/manual/index.html', home_label => 'Manual', default_title => 'Manual Gymmix' },
    { code => 'fr-ca',   label => '🇨🇦 Français (Canada)', href => $root_prefix . 'fr-ca/manual/index.html', home_label => 'Manuel', default_title => 'Manuel Gymmix' },
    { code => 'zh-hant', label => '🇹🇼 繁體中文',   href => $root_prefix . 'zh-hant/manual/index.html', home_label => '手冊',        default_title => 'Gymmix 手冊' },
    { code => 'cs',      label => '🇨🇿 Čeština',   href => $root_prefix . 'cs/manual/index.html',      home_label => 'Manuál',      default_title => 'Manuál Gymmix' },
    { code => 'uk',      label => '🇺🇦 Українська', href => $root_prefix . 'uk/manual/index.html',    home_label => 'Посібник',    default_title => 'Посібник Gymmix' },
    { code => 'pl',      label => '🇵🇱 Polski',    href => $root_prefix . 'pl/manual/index.html',      home_label => 'Podręcznik',  default_title => 'Podręcznik Gymmix' },
    { code => 'th',      label => '🇹🇭 ไทย',        href => $root_prefix . 'th/manual/index.html',      home_label => 'คู่มือ',        default_title => 'คู่มือ Gymmix' },
    { code => 'ar',      label => '🇸🇦 العربية',    href => $root_prefix . 'ar/manual/index.html',      home_label => 'الدليل',      default_title => 'دليل Gymmix' },
    { code => 'id',      label => '🇮🇩 Bahasa Indonesia', href => $root_prefix . 'id/manual/index.html', home_label => 'Panduan', default_title => 'Panduan Gymmix' },
    { code => 'fil',     label => '🇵🇭 Filipino',  href => $root_prefix . 'fil/manual/index.html',     home_label => 'Manwal',      default_title => 'Manwal ng Gymmix' },
    { code => 'he',      label => '🇮🇱 עברית',     href => $root_prefix . 'he/manual/index.html',      home_label => 'מדריך',       default_title => 'מדריך Gymmix' },
    { code => 'nb',      label => '🇳🇴 Norsk Bokmål', href => $root_prefix . 'nb/manual/index.html',  home_label => 'Håndbok',     default_title => 'Gymmix Håndbok' },
    { code => 'tr',      label => '🇹🇷 Türkçe',    href => $root_prefix . 'tr/manual/index.html',      home_label => 'Kılavuz',     default_title => 'Gymmix Kılavuzu' },
    { code => 'ja',      label => '🇯🇵 日本語',      href => $root_prefix . 'ja/manual/index.html',      home_label => 'マニュアル',      default_title => 'Gymmix マニュアル' },
    { code => 'ko',      label => '🇰🇷 한국어',      href => $root_prefix . 'ko/manual/index.html',      home_label => '매뉴얼',        default_title => 'Gymmix 매뉴얼' },
    { code => 'ky',      label => '🇰🇬 Кыргызча',   href => $root_prefix . 'ky/manual/index.html',      home_label => 'Колдонмо',     default_title => 'Gymmix Колдонмосу' },
    { code => 'kk',      label => '🇰🇿 Қазақша',    href => $root_prefix . 'kk/manual/index.html',      home_label => 'Нұсқаулық',    default_title => 'Gymmix Нұсқаулығы' },
    { code => 'ru',      label => '🇷🇺 Русский',   href => $root_prefix . 'ru/manual/index.html',      home_label => 'Руководство', default_title => 'Руководство Gymmix' },
    { code => 'it',      label => '🇮🇹 Italiano',  href => $root_prefix . 'it/manual/index.html',      home_label => 'Manuale',     default_title => 'Manuale Gymmix' },
    { code => 'lt',      label => '🇱🇹 Lietuvių',  href => $root_prefix . 'lt/manual/index.html',      home_label => 'Vadovas',     default_title => 'Gymmix Vadovas' },
    { code => 'et',      label => '🇪🇪 Eesti',     href => $root_prefix . 'et/manual/index.html',      home_label => 'Juhend',      default_title => 'Gymmix Juhend' },
    { code => 'lv',      label => '🇱🇻 Latviešu',  href => $root_prefix . 'lv/manual/index.html',      home_label => 'Rokasgrāmata', default_title => 'Gymmix Rokasgrāmata' },
    { code => 'ms',      label => '🇲🇾 Bahasa Melayu', href => $root_prefix . 'ms/manual/index.html',  home_label => 'Manual',      default_title => 'Manual Gymmix' },
    { code => 'sv',      label => '🇸🇪 Svenska',   href => $root_prefix . 'sv/manual/index.html',      home_label => 'Handbok',     default_title => 'Gymmix Handbok' },
    { code => 'nl',      label => '🇳🇱 Nederlands', href => $root_prefix . 'nl/manual/index.html',     home_label => 'Handleiding', default_title => 'Gymmix Handleiding' },
    { code => 'da',      label => '🇩🇰 Dansk',     href => $root_prefix . 'da/manual/index.html',      home_label => 'Håndbog',     default_title => 'Gymmix Håndbog' },
    { code => 'fi',      label => '🇫🇮 Suomi',     href => $root_prefix . 'fi/manual/index.html',      home_label => 'Käyttöopas',  default_title => 'Gymmix Käyttöopas' },
    { code => 'el',      label => '🇬🇷 Ελληνικά',  href => $root_prefix . 'el/manual/index.html',      home_label => 'Εγχειρίδιο',  default_title => 'Εγχειρίδιο Gymmix' },
    { code => 'hr',      label => '🇭🇷 Hrvatski',  href => $root_prefix . 'hr/manual/index.html',      home_label => 'Priručnik',   default_title => 'Gymmix Priručnik' },
    { code => 'ro',      label => '🇷🇴 Română',    href => $root_prefix . 'ro/manual/index.html',      home_label => 'Manual',      default_title => 'Manual Gymmix' },
    { code => 'sk',      label => '🇸🇰 Slovenčina', href => $root_prefix . 'sk/manual/index.html',     home_label => 'Príručka',    default_title => 'Príručka Gymmix' },
    { code => 'hu',      label => '🇭🇺 Magyar',    href => $root_prefix . 'hu/manual/index.html',      home_label => 'Kézikönyv',   default_title => 'Gymmix Kézikönyv' },
);
my %language_lookup = map { $_->{code} => $_ } @language_options;
my $lang_info = $language_lookup{$lang} // $language_lookup{'en'};

my $page_title = $lang_info->{default_title};
my $home_label = $lang_info->{home_label};
my $css_href = $root_prefix . 'assets/handbook.css';

my $current_lang_label = $lang_info->{label};

my %html_lang_map = (
    'zh-hans' => 'zh-Hans',
    'zh-hant' => 'zh-Hant',
    'pt-pt'   => 'pt-PT',
    'pt-br'   => 'pt-BR',
    'fr-ca'   => 'fr-CA',
);
my $html_lang = $html_lang_map{$lang} // $lang;
my %rtl_langs = map { $_ => 1 } qw(ar he);
my $html_dir = $rtl_langs{$lang} ? 'rtl' : 'ltr';

my $language_items = join '', map {
    my $active = $_->{code} eq $lang ? ' class="active"' : '';
    my $label = $_->{label};
    my $href = $_->{href};
    $_->{code} eq $lang
        ? qq{      <li$active><span>$label</span></li>\n}
        : qq{      <li$active><a href="$href">$label</a></li>\n};
} @language_options;

my $language_menu = <<"HTML";
<details class="lang-switcher">
          <summary>$current_lang_label</summary>
          <ul>
$language_items          </ul>
        </details>
HTML

my $body = '';
my $in_p = 0;
my $in_ul = 0;
my $in_ol = 0;
my %seen_heading_ids;

sub unique_heading_id {
    my ($text, $seen_ref) = @_;
    my $base = slugify($text);
    my $id = $base;
    my $suffix = 2;
    while (exists $seen_ref->{$id}) {
        $id = $base . "-" . $suffix;
        $suffix++;
    }
    $seen_ref->{$id} = 1;
    return $id;
}

sub close_p {
    my ($body_ref, $in_p_ref) = @_;
    if ($$in_p_ref) {
        $$body_ref .= "</p>\n";
        $$in_p_ref = 0;
    }
}

sub close_ul {
    my ($body_ref, $in_ul_ref) = @_;
    if ($$in_ul_ref) {
        $$body_ref .= "</ul>\n";
        $$in_ul_ref = 0;
    }
}

sub close_ol {
    my ($body_ref, $in_ol_ref) = @_;
    if ($$in_ol_ref) {
        $$body_ref .= "</ol>\n";
        $$in_ol_ref = 0;
    }
}

foreach my $raw_line (@lines) {
    my $line = $raw_line;
    $line =~ s/\r?\n$//;

    if ($line =~ /^\s*$/) {
        close_p(\$body, \$in_p);
        close_ul(\$body, \$in_ul);
        close_ol(\$body, \$in_ol);
        next;
    }

    if ($line =~ /^#\s+(.+)$/) {
        close_p(\$body, \$in_p);
        close_ul(\$body, \$in_ul);
        close_ol(\$body, \$in_ol);
        my $raw = $1;
        my $h = inline_markdown($raw);
        my $id = unique_heading_id($raw, \%seen_heading_ids);
        $body .= "<h1 id=\"$id\">$h</h1>\n";
        $page_title = $raw;
        next;
    }

    if ($line =~ /^##\s+(.+)$/) {
        close_p(\$body, \$in_p);
        close_ul(\$body, \$in_ul);
        close_ol(\$body, \$in_ol);
        my $raw = $1;
        my $h = inline_markdown($raw);
        my $id = unique_heading_id($raw, \%seen_heading_ids);
        $body .= "<h2 id=\"$id\">$h</h2>\n";
        next;
    }

    if ($line =~ /^###\s+(.+)$/) {
        close_p(\$body, \$in_p);
        close_ul(\$body, \$in_ul);
        close_ol(\$body, \$in_ol);
        my $raw = $1;
        my $h = inline_markdown($raw);
        my $id = unique_heading_id($raw, \%seen_heading_ids);
        $body .= "<h3 id=\"$id\">$h</h3>\n";
        next;
    }

    if ($line =~ /^\-\s+(.+)$/) {
        close_p(\$body, \$in_p);
        close_ol(\$body, \$in_ol);
        if (!$in_ul) {
            $body .= "<ul>\n";
            $in_ul = 1;
        }
        my $item = inline_markdown($1);
        $body .= "  <li>$item</li>\n";
        next;
    }

    if ($line =~ /^\d+\.\s+(.+)$/) {
        close_p(\$body, \$in_p);
        close_ul(\$body, \$in_ul);
        if (!$in_ol) {
            $body .= "<ol>\n";
            $in_ol = 1;
        }
        my $item = inline_markdown($1);
        $body .= "  <li>$item</li>\n";
        next;
    }

    close_ul(\$body, \$in_ul);
    close_ol(\$body, \$in_ol);

    my $text = inline_markdown($line);
    if (!$in_p) {
        $body .= "<p>$text";
        $in_p = 1;
    } else {
        $body .= "<br />$text";
    }
}

close_p(\$body, \$in_p);
close_ul(\$body, \$in_ul);
close_ol(\$body, \$in_ol);

my $html = <<"HTML";
<!doctype html>
<html lang="$html_lang" dir="$html_dir">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>$page_title</title>
  <link rel="stylesheet" href="$css_href" />
</head>
<body>
  <header class="topbar">
    <div class="topbar-inner">
      <a class="brand" href="$index_href">$home_label</a>
      <nav class="topnav">
$language_menu
      </nav>
    </div>
  </header>
  <main class="container">
$body
  </main>
</body>
</html>
HTML

open my $out_fh, '>', $output_path or die "Cannot write $output_path: $!";
print {$out_fh} $html;
close $out_fh;
