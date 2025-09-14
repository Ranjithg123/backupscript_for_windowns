Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

# Function: Show notifications
function Show-Notification {
    param (
        [string]$Title = "Backup Tool",
        [string]$Message = "Task Completed",
        [string]$Type = "Info"
    )

    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.SystemIcons]::Information
    $notify.Visible = $true

    switch ($Type) {
        "Success" { $notify.Icon = [System.Drawing.SystemIcons]::Asterisk }
        "Error"   { $notify.Icon = [System.Drawing.SystemIcons]::Error }
        default   { $notify.Icon = [System.Drawing.SystemIcons]::Information }
    }

    $notify.ShowBalloonTip(5000, $Title, $Message, [System.Windows.Forms.ToolTipIcon]::None)
}

# Function: Run backup
function Run-Backup {
    param($Source, $Dest)

    try {
        $date = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = Join-Path $Dest "Backup_$date.zip"

        # Compress and save backup
        Compress-Archive -Path $Source -DestinationPath $backupFile -Force

        # Delete backups older than 3 days
        Get-ChildItem -Path $Dest -Filter "Backup_*.zip" |
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-3) } |
            Remove-Item -Force

        Show-Notification -Title "Backup Completed" -Message "Stored at $backupFile" -Type "Success"
    }
    catch {
        Show-Notification -Title "Backup Failed" -Message $_.Exception.Message -Type "Error"
    }
}

# ---------- UI DESIGN ----------
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Modern Backup Tool" Height="380" Width="560"
        WindowStartupLocation="CenterScreen"
        Background="#1E1E1E" Foreground="White" FontFamily="Segoe UI" FontSize="14">
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>

        <!-- Source -->
        <TextBlock Text="Source Folder:" Grid.Row="0" Margin="0,0,0,5"/>
        <Grid Grid.Row="0" Margin="0,20,0,0">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="100"/>
            </Grid.ColumnDefinitions>
            <TextBox x:Name="txtSource" Grid.Column="0" Height="32"
                     Background="#2D2D30" Foreground="White" Padding="6" BorderThickness="0"/>
            <Button x:Name="btnSource" Grid.Column="1" Content="Browse"
                    Background="#0078D7" Foreground="White" BorderThickness="0" Height="32" Margin="8,0,0,0"/>
        </Grid>

        <!-- Destination -->
        <TextBlock Text="Destination (Mounted Storage):" Grid.Row="1" Margin="0,20,0,5"/>
        <Grid Grid.Row="1" Margin="0,20,0,0">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="100"/>
            </Grid.ColumnDefinitions>
            <TextBox x:Name="txtDest" Grid.Column="0" Height="32"
                     Background="#2D2D30" Foreground="White" Padding="6" BorderThickness="0"/>
            <Button x:Name="btnDest" Grid.Column="1" Content="Browse"
                    Background="#0078D7" Foreground="White" BorderThickness="0" Height="32" Margin="8,0,0,0"/>
        </Grid>

        <!-- Time -->
        <TextBlock Text="Backup Time (24hr HH:MM):" Grid.Row="2" Margin="0,20,0,5"/>
        <TextBox x:Name="txtTime" Grid.Row="2" Margin="0,50,0,0" Width="120" Height="32"
                 Text="23:00" Background="#2D2D30" Foreground="White" BorderThickness="0" Padding="6"/>

        <!-- Buttons -->
        <StackPanel Grid.Row="3" Orientation="Horizontal" Margin="0,30,0,0" HorizontalAlignment="Center">
            <Button x:Name="btnSchedule" Content="Schedule Backup" Width="180" Height="36" Margin="10,0"
                    Background="#28a745" Foreground="White" BorderThickness="0" Padding="8"/>
            <Button x:Name="btnRunNow" Content="Run Now" Width="140" Height="36" Margin="10,0"
                    Background="#ffc107" Foreground="Black" BorderThickness="0" Padding="8"/>
        </StackPanel>

        <!-- Status -->
        <TextBlock x:Name="lblStatus" Grid.Row="4" Text="Status: Waiting..."
                   Margin="0,25,0,0" TextWrapping="Wrap"/>
    </Grid>
</Window>
"@

# Load XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Link controls
$txtSource   = $Window.FindName("txtSource")
$txtDest     = $Window.FindName("txtDest")
$txtTime     = $Window.FindName("txtTime")
$btnSource   = $Window.FindName("btnSource")
$btnDest     = $Window.FindName("btnDest")
$btnRunNow   = $Window.FindName("btnRunNow")
$btnSchedule = $Window.FindName("btnSchedule")
$lblStatus   = $Window.FindName("lblStatus")

# Folder pickers
$btnSource.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq "OK") { $txtSource.Text = $dialog.SelectedPath }
})
$btnDest.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq "OK") { $txtDest.Text = $dialog.SelectedPath }
})

# Run Now
$btnRunNow.Add_Click({
    if ($txtSource.Text -and $txtDest.Text) {
        $lblStatus.Text = "Running backup..."
        Run-Backup -Source $txtSource.Text -Dest $txtDest.Text
        $lblStatus.Text = "Backup Completed."
    }
    else {
        [System.Windows.MessageBox]::Show("Select Source and Destination first.")
    }
})

# Schedule
$btnSchedule.Add_Click({
    $lblStatus.Text = "Scheduled backup at " + $txtTime.Text
    $jobScript = {
        param($s,$d)
        Run-Backup -Source $s -Dest $d
    }
    # Remove existing job if it exists
if (Get-ScheduledJob -Name "AutoBackupJob" -ErrorAction SilentlyContinue) {
    Unregister-ScheduledJob -Name "AutoBackupJob" -Confirm:$false
}

# Register new job
Register-ScheduledJob -Name "AutoBackupJob" -ScriptBlock $jobScript -ArgumentList $txtSource.Text,$txtDest.Text -Trigger (New-JobTrigger -Daily -At $txtTime.Text)

    Show-Notification -Title "Backup Scheduled" -Message "Daily at $($txtTime.Text)" -Type "Info"
})

# ---------- TRAY ICON ----------
$tray = New-Object System.Windows.Forms.NotifyIcon
$tray.Icon = [System.Drawing.SystemIcons]::Application
$tray.Visible = $true
$tray.Text = "Backup Tool"

# Tray menu
$menu = New-Object System.Windows.Forms.ContextMenu
$exitItem = New-Object System.Windows.Forms.MenuItem "Exit"
$exitItem.add_Click({
    $tray.Visible = $false
    $Window.Close()
})
$menu.MenuItems.Add($exitItem)
$tray.ContextMenu = $menu

# Run window
$Window.ShowDialog() | Out-Null
