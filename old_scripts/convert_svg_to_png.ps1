# Convert SVG files to PNG using Chrome or Edge via puppeteer
# This script converts existing SVG files to PNG format

# Define the directories for input and output files
$svgDir = "C:\DPIA DFD\svg_exports"
$outputDir = "C:\DPIA DFD\svg_exports"

# Ensure the output directory exists
if (!(Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
    Write-Host "Created output directory: $outputDir"
}

# Install puppeteer-core if not already installed
Write-Host "Installing required packages..." -ForegroundColor Yellow
npm install puppeteer-core --save-dev

# Create a temporary JavaScript file for the conversion
$tempJsFile = Join-Path -Path $env:TEMP -ChildPath "svg_to_png_converter.js"

$jsContent = @'
const puppeteer = require("puppeteer-core");
const fs = require("fs");
const path = require("path");

async function convertSvgToPng(svgPath, pngPath) {
  // Find Chrome or Edge in standard locations
  const findChromePath = () => {
    const possiblePaths = [
      "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
      "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe",
      "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
      "C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe"
    ];
    
    for (const path of possiblePaths) {
      if (fs.existsSync(path)) {
        return path;
      }
    }
    throw new Error("Could not find Chrome or Edge browser. Please install one of them.");
  };

  const browser = await puppeteer.launch({
    executablePath: findChromePath(),
    headless: "new"
  });
  
  try {
    const page = await browser.newPage();
    
    // Read SVG content
    const svgContent = fs.readFileSync(svgPath, "utf8");
    
    // Set viewport to match SVG dimensions
    await page.setViewport({
      width: 1200,
      height: 800,
      deviceScaleFactor: 2
    });
    
    // Create HTML with embedded SVG (using simpler inline HTML to avoid template issues)
    const html = "<!DOCTYPE html><html><head><style>body,html{margin:0;padding:0;background-color:white;height:100%;}svg{max-width:100%;height:auto;}</style></head><body>" + svgContent + "</body></html>";
    await page.setContent(html);
    
    // Wait for any rendering to complete
    await page.waitForTimeout(1000);
    
    // Take a screenshot
    await page.screenshot({
      path: pngPath,
      fullPage: true,
      omitBackground: false
    });
    
    console.log("Converted " + path.basename(svgPath) + " to PNG");
  } catch (error) {
    console.error("Error converting " + path.basename(svgPath) + ": " + error.message);
    throw error;
  } finally {
    await browser.close();
  }
}

// Get command line arguments for paths
const svgPath = process.argv[2];
const pngPath = process.argv[3];

// Run the conversion
convertSvgToPng(svgPath, pngPath)
  .then(() => console.log("Conversion complete"))
  .catch(err => {
    console.error("Conversion failed:", err);
    process.exit(1);
  });
'@

$jsContent | Out-File -FilePath $tempJsFile -Encoding UTF8

# List of SVG files to convert
$svgFiles = @(
    "data_retention_deletion.svg",
    "external_data_sharing.svg",
    "high_level_overview.svg",
    "transaction_processing_detail.svg"
)

# Process each SVG file
foreach ($svgFile in $svgFiles) {
    # Get the base name without extension
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($svgFile)
    $svgPath = Join-Path -Path $svgDir -ChildPath $svgFile
    $outputPngPath = Join-Path -Path $outputDir -ChildPath "$baseName.png"
    
    Write-Host "Processing $baseName..." -ForegroundColor Cyan
    
    try {
        Write-Host "  Converting SVG to PNG for $baseName..." -NoNewline
        # Use Node.js to run the converter script
        $process = Start-Process -FilePath "node" -ArgumentList "`"$tempJsFile`" `"$svgPath`" `"$outputPngPath`"" -NoNewWindow -PassThru -Wait
        
        if ($process.ExitCode -eq 0) {
            Write-Host " Done" -ForegroundColor Green
            Write-Host "  Successfully created $outputPngPath" -ForegroundColor Green
        } else {
            Write-Host " Failed (Exit code: $($process.ExitCode))" -ForegroundColor Red
            Write-Host "  Failed to generate $outputPngPath" -ForegroundColor Red
        }
    } catch {
        Write-Host "Error converting SVG to PNG for $baseName - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Clean up the temporary file
if (Test-Path $tempJsFile) {
    Remove-Item $tempJsFile -Force
}

Write-Host "`nProcess completed! Check $outputDir for the generated PNG files." -ForegroundColor Green
Write-Host "If you encounter any issues, make sure you have Node.js, Chrome or Microsoft Edge installed."
