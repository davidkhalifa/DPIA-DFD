# Script to convert Markdown files to HTML with proper Mermaid support
# Final version with all fixes

# Ensure HTML_Pages directory exists
$htmlDir = "C:\DPIA DFD\HTML_Pages"
if (-not (Test-Path -Path $htmlDir)) {
    New-Item -Path $htmlDir -ItemType Directory
}

# Get all markdown files
$markdownFiles = Get-ChildItem -Path "C:\DPIA DFD" -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }

foreach ($mdFile in $markdownFiles) {
    Write-Host "Processing $($mdFile.Name)..."
    
    # Read the markdown content
    $markdownContent = Get-Content -Path $mdFile.FullName -Raw
    
    # Remove filepath comments
    $markdownContent = $markdownContent -replace '<!-- filepath: .*? -->', ''
    
    # Extract the title from the markdown
    $titleMatch = [regex]::Match($markdownContent, '# (.*)')
    $title = if ($titleMatch.Success) { $titleMatch.Groups[1].Value } else { $mdFile.BaseName }
    
    # Generate HTML content with Mermaid support
    $htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <!-- Mermaid library -->
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            mermaid.initialize({
                startOnLoad: true,
                theme: 'neutral',
                fontFamily: 'Segoe UI'
            });
        });
    </script>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f9f9f9;
        }
        h1, h2, h3 {
            color: #0078d4;
        }
        h1 {
            border-bottom: 2px solid #0078d4;
            padding-bottom: 10px;
        }
        h2 {
            margin-top: 30px;
            border-bottom: 1px solid #ddd;
            padding-bottom: 5px;
        }
        pre {
            background-color: #f6f8fa;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 16px;
            overflow: auto;
        }
        code {
            font-family: Consolas, Monaco, 'Courier New', monospace;
        }
        .mermaid {
            text-align: center;
            margin: 30px 0;
            padding: 15px 0;
        }
        ul, ol {
            padding-left: 25px;
        }
        li {
            margin-bottom: 8px;
        }
        p {
            margin-bottom: 16px;
        }
        strong {
            font-weight: bold;
        }
        blockquote {
            border-left: 4px solid #0078d4;
            padding-left: 16px;
            margin-left: 0;
            color: #666;
        }
        a {
            color: #0078d4;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .menu {
            margin-bottom: 30px;
            background-color: #f5f5f5;
            padding: 15px;
            border-radius: 4px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .menu a {
            margin-right: 15px;
            padding: 5px 10px;
            font-weight: 500;
            border-radius: 4px;
        }
        .menu a:hover {
            background-color: #e0e0e0;
            text-decoration: none;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="menu">
            <a href="high_level_overview.html">High Level Overview</a>
            <a href="data_retention_deletion.html">Data Retention & Deletion</a>
            <a href="external_data_sharing.html">External Data Sharing</a>
            <a href="transaction_processing_detail.html">Transaction Processing</a>
            <a href="index.html">Home</a>
        </div>

"@

    # Extract Mermaid code blocks
    $mermaidPattern = '```mermaid([\s\S]*?)```'
    $mermaidBlocks = [regex]::Matches($markdownContent, $mermaidPattern)
    
    # Replace Mermaid blocks with placeholders
    $contentWithPlaceholders = $markdownContent
    for ($i = 0; $i -lt $mermaidBlocks.Count; $i++) {
        $contentWithPlaceholders = $contentWithPlaceholders.Replace($mermaidBlocks[$i].Value, "MERMAID_PLACEHOLDER_$i")
    }
    
    # Process headers
    $contentWithPlaceholders = $contentWithPlaceholders -replace '# (.*)', '<h1>$1</h1>'
    $contentWithPlaceholders = $contentWithPlaceholders -replace '## (.*)', '<h2>$1</h2>'
    $contentWithPlaceholders = $contentWithPlaceholders -replace '### (.*)', '<h3>$1</h3>'
    
    # Process bold text
    $contentWithPlaceholders = $contentWithPlaceholders -replace '\*\*(.*?)\*\*', '<strong>$1</strong>'
    
    # Process lists
    $contentWithPlaceholders = $contentWithPlaceholders -replace '(?m)^- (.*?)$', '<li>$1</li>'
    $contentWithPlaceholders = $contentWithPlaceholders -replace '(?s)(<li>.*?</li>\s*)+', '<ul>$0</ul>'
    
    # Process paragraphs
    $lines = $contentWithPlaceholders -split "\r?\n\r?\n"
    $processedLines = @()
    
    foreach ($line in $lines) {
        $trimmedLine = $line.Trim()
        if ($trimmedLine.Length -gt 0 -and -not ($trimmedLine -match '^<h[1-6]|^<ul|^<li|^<pre|^<div|^MERMAID_PLACEHOLDER')) {
            $processedLines += "<p>$trimmedLine</p>"
        } else {
            $processedLines += $trimmedLine
        }
    }
    
    $contentWithPlaceholders = $processedLines -join "`n`n"
    
    # Restore Mermaid blocks
    for ($i = 0; $i -lt $mermaidBlocks.Count; $i++) {
        $mermaidContent = $mermaidBlocks[$i].Groups[1].Value.Trim()
        $contentWithPlaceholders = $contentWithPlaceholders.Replace("MERMAID_PLACEHOLDER_$i", "<div class='mermaid'>$mermaidContent</div>")
    }
    
    # Add the processed content to the HTML
    $htmlContent += $contentWithPlaceholders
    
    # Close the HTML
    $htmlContent += @"

    </div>
</body>
</html>
"@
    
    # Save the HTML file
    $htmlFilePath = Join-Path -Path $htmlDir -ChildPath "$($mdFile.BaseName).html"
    $htmlContent | Out-File -FilePath $htmlFilePath -Encoding utf8
    
    Write-Host "Created $htmlFilePath"
}

# Create index.html
$indexHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Microsoft Commerce Financial Platforms (CFP) - Data Flow Diagrams</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f9f9f9;
        }
        h1, h2 {
            color: #0078d4;
        }
        h1 {
            border-bottom: 2px solid #0078d4;
            padding-bottom: 10px;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        }
        .card-container {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-top: 30px;
        }
        .card {
            flex: 1 0 45%;
            min-width: 300px;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 20px;
            background-color: #fff;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .card h2 {
            margin-top: 0;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }
        .card p {
            color: #666;
        }
        .card a {
            display: inline-block;
            margin-top: 15px;
            padding: 8px 15px;
            background-color: #0078d4;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s ease;
        }
        .card a:hover {
            background-color: #005a9e;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Microsoft Commerce Financial Platforms (CFP)</h1>
        <p>This collection of data flow diagrams illustrates how personal data flows through Microsoft's Commerce Financial Platforms (CFP) system.</p>
        
        <div class="card-container">
            <div class="card">
                <h2>High Level Overview</h2>
                <p>A high-level overview of personal data flows through Microsoft's Commerce Financial Platforms (CFP) system, from collection to deletion.</p>
                <a href="high_level_overview.html">View Diagram</a>
            </div>
            
            <div class="card">
                <h2>Data Retention & Deletion</h2>
                <p>Detailed flow showing the lifecycle, retention, and deletion processes for personal data in the CFP system.</p>
                <a href="data_retention_deletion.html">View Diagram</a>
            </div>
            
            <div class="card">
                <h2>External Data Sharing</h2>
                <p>Focuses on data transfers across trust boundaries, particularly when personal data leaves Microsoft's system and is shared with third parties.</p>
                <a href="external_data_sharing.html">View Diagram</a>
            </div>
            
            <div class="card">
                <h2>Transaction Processing Detail</h2>
                <p>A detailed view of the transaction processing flow, focusing on how customer payment data is handled.</p>
                <a href="transaction_processing_detail.html">View Diagram</a>
            </div>
        </div>
    </div>
</body>
</html>
"@

$indexFilePath = Join-Path -Path $htmlDir -ChildPath "index.html"
$indexHtml | Out-File -FilePath $indexFilePath -Encoding utf8
Write-Host "Created index.html"

Write-Host "HTML conversion completed. Files saved to $htmlDir"
