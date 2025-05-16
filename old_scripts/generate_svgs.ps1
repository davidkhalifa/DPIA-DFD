$files = @(
    "data_retention_deletion.md",
    "external_data_sharing.md",
    "high_level_overview.md",
    "transaction_processing_detail.md"
)

foreach ($file in $files) {
    # Get the base name without extension
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
    $outputFile = "svg_exports\$baseName.svg"
    
    # Create a temporary file to hold just the Mermaid content
    $content = Get-Content $file -Raw
    # Extract content between ```mermaid and ``` markers
    if ($content -match '```mermaid\s*([\s\S]*?)```') {
        $mermaidContent = $matches[1].Trim()
        $mermaidContent | Out-File -FilePath "temp_diagram.mmd" -Encoding UTF8
        
        Write-Host "Generating SVG for $file..."
        mmdc -i "temp_diagram.mmd" -o $outputFile -b transparent
    } else {
        Write-Host "No mermaid content found in $file"
    }
}

# Clean up the temporary file
if (Test-Path "temp_diagram.mmd") {
    Remove-Item "temp_diagram.mmd"
}

Write-Host "All SVGs generated in the svg_exports directory"
