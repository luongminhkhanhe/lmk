
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

$form = New-Object System.Windows.Forms.Form
$form.Text = "LMK Linux Builder - RK3229"
$form.Size = New-Object System.Drawing.Size(720,520)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$title = New-Object System.Windows.Forms.Label
$title.Text = "LMK Linux Builder for VINABOX X9"
$title.Font = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(20,18)
$form.Controls.Add($title)

$sub = New-Object System.Windows.Forms.Label
$sub.Text = "RK3229 • TXCZ-RK3229-V2.3 • 2 GB RAM • 8 GB raw NAND"
$sub.AutoSize = $true
$sub.Location = New-Object System.Drawing.Point(22,55)
$form.Controls.Add($sub)

$status = New-Object System.Windows.Forms.TextBox
$status.Multiline = $true
$status.ReadOnly = $true
$status.ScrollBars = "Vertical"
$status.Font = New-Object System.Drawing.Font("Consolas",10)
$status.Location = New-Object System.Drawing.Point(20,95)
$status.Size = New-Object System.Drawing.Size(660,260)
$form.Controls.Add($status)

function Log([string]$text) {
    $status.AppendText("[$(Get-Date -Format HH:mm:ss)] $text`r`n")
}

$check = New-Object System.Windows.Forms.Button
$check.Text = "1. KIỂM TRA BỘ FILE"
$check.Location = New-Object System.Drawing.Point(20,375)
$check.Size = New-Object System.Drawing.Size(205,42)
$check.Add_Click({
    Log "Đang kiểm tra..."
    $required = @(
        ".github\workflows\build.yml",
        "board\txcz-rk3229-v2.3-original.dtb",
        "scripts\cloud-build.sh"
    )
    $ok = $true
    foreach ($rel in $required) {
        $p = Join-Path $Root $rel
        if (Test-Path $p) {
            Log "OK: $rel"
        } else {
            Log "THIẾU: $rel"
            $ok = $false
        }
    }
    if ($ok) {
        Log "Bộ Builder hợp lệ."
    } else {
        Log "Bộ Builder chưa đầy đủ."
    }
})
$form.Controls.Add($check)

$open = New-Object System.Windows.Forms.Button
$open.Text = "2. MỞ GITHUB"
$open.Location = New-Object System.Drawing.Point(245,375)
$open.Size = New-Object System.Drawing.Size(205,42)
$open.Add_Click({
    Start-Process "https://github.com/new"
    Log "Đã mở trang tạo repository GitHub."
})
$form.Controls.Add($open)

$folder = New-Object System.Windows.Forms.Button
$folder.Text = "3. MỞ THƯ MỤC UPLOAD"
$folder.Location = New-Object System.Drawing.Point(470,375)
$folder.Size = New-Object System.Drawing.Size(210,42)
$folder.Add_Click({
    Start-Process explorer.exe $Root
    Log "Đã mở thư mục Builder."
})
$form.Controls.Add($folder)

$guide = New-Object System.Windows.Forms.Button
$guide.Text = "XEM HƯỚNG DẪN"
$guide.Location = New-Object System.Drawing.Point(20,430)
$guide.Size = New-Object System.Drawing.Size(205,35)
$guide.Add_Click({
    Start-Process notepad.exe (Join-Path $Root "HUONG_DAN.txt")
})
$form.Controls.Add($guide)

$warning = New-Object System.Windows.Forms.Label
$warning.Text = "Lưu ý: công cụ Windows này điều khiển máy build Linux trên GitHub; nó không tự flash NAND."
$warning.AutoSize = $true
$warning.ForeColor = [System.Drawing.Color]::DarkRed
$warning.Location = New-Object System.Drawing.Point(245,439)
$form.Controls.Add($warning)

Log "Sẵn sàng."
Log "Bấm Kiểm tra bộ file, sau đó mở GitHub và làm theo HUONG_DAN.txt."
[void]$form.ShowDialog()
