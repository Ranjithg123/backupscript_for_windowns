# Pro Backup Manager v2.0 Professional
# Modern backup solution with professional UI
# Author: AI Assistant
# Date: $(Get-Date -Format "yyyy-MM-dd")

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

# Function: Show professional notifications
function Show-Notification {
    param (
        [string]$Title = "Pro Backup Manager",
        [string]$Message = "Task Completed",
        [string]$Type = "Info"
    )

    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.SystemIcons]::Information
    $notify.Visible = $true

    switch ($Type) {
        "Success" { 
            $notify.Icon = [System.Drawing.SystemIcons]::Asterisk
            $notify.ShowBalloonTip(5000, $Title, $Message, [System.Windows.Forms.ToolTipIcon]::Info)
        }
        "Error"   { 
            $notify.Icon = [System.Drawing.SystemIcons]::Error
            $notify.ShowBalloonTip(7000, $Title, $Message, [System.Windows.Forms.ToolTipIcon]::Error)
        }
        default   { 
            $notify.Icon = [System.Drawing.SystemIcons]::Information
            $notify.ShowBalloonTip(5000, $Title, $Message, [System.Windows.Forms.ToolTipIcon]::Info)
        }
    }
}

# Function: Update status indicator
function Update-StatusIndicator {
    param([string]$Status)
    
    switch ($Status) {
        "ready" { 
            $statusIndicator.Fill = "#238636"
            $lblStatus.Text = "Ready to backup"
            $lblStatus.Foreground = "#7D8590"
        }
        "running" { 
            $statusIndicator.Fill = "#F0C674"
            $lblStatus.Text = "Backup in progress..."
            $lblStatus.Foreground = "#F0C674"
            $progressBar.Visibility = "Visible"
        }
        "success" { 
            $statusIndicator.Fill = "#238636"
            $lblStatus.Text = "Backup completed successfully"
            $lblStatus.Foreground = "#238636"
            $progressBar.Visibility = "Collapsed"
        }
        "error" { 
            $statusIndicator.Fill = "#F85149"
            $lblStatus.Text = "Backup failed"
            $lblStatus.Foreground = "#F85149"
            $progressBar.Visibility = "Collapsed"
        }
    }
}

# Function: Start backup with enhanced UI feedback
function Start-Backup {
    param($Source, $Dest)

    try {
        Update-StatusIndicator "running"
        $progressBar.IsIndeterminate = $true
        
        $date = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = Join-Path $Dest "Backup_$date.zip"

        # Compress and save backup
        Compress-Archive -Path $Source -DestinationPath $backupFile -Force

        # Delete backups older than 3 days
        Get-ChildItem -Path $Dest -Filter "Backup_*.zip" |
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-3) } |
            Remove-Item -Force

        Update-StatusIndicator "success"
        Show-Notification -Title "Backup Completed" -Message "Stored at $backupFile" -Type "Success"
    }
    catch {
        Update-StatusIndicator "error"
        Show-Notification -Title "Backup Failed" -Message $_.Exception.Message -Type "Error"
    }
}

# ---------- UI DESIGN ----------
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Pro Backup Manager" Height="600" Width="720"
        WindowStartupLocation="CenterScreen" ResizeMode="CanMinimize"
        Background="#0D1117" Foreground="#F0F6FC" FontFamily="Segoe UI" FontSize="13" TextOptions.TextRenderingMode="ClearType"
        WindowStyle="None" AllowsTransparency="True">
    
    <!-- Window Border and Shadow -->
    <Border Background="#161B22" CornerRadius="12" BorderBrush="#30363D" BorderThickness="1">
        <Border.Effect>
            <DropShadowEffect Color="Black" Direction="270" ShadowDepth="8" BlurRadius="20" Opacity="0.3"/>
        </Border.Effect>
        
        <Grid Margin="0">
            <Grid.RowDefinitions>
                <RowDefinition Height="60"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="80"/>
            </Grid.RowDefinitions>
            
            <!-- Title Bar -->
            <Grid Grid.Row="0" Background="#21262D">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="120"/>
                </Grid.ColumnDefinitions>
                
                <StackPanel Grid.Column="0" Orientation="Horizontal" Margin="20,0,0,0" VerticalAlignment="Center">
                    <Ellipse Width="32" Height="32" Fill="#238636" Margin="0,0,12,0"/>
                    <StackPanel VerticalAlignment="Center">
                        <TextBlock Text="Pro Backup Manager" FontSize="16" FontWeight="SemiBold" Foreground="#F0F6FC"/>
                        <TextBlock Text="Professional backup solution" FontSize="11" Foreground="#7D8590"/>
                    </StackPanel>
                </StackPanel>
                
                <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,0,10,0">
                    <Button x:Name="btnTheme" Content="T" Width="30" Height="30" Margin="2" 
                            Background="Transparent" Foreground="#F0F6FC" BorderThickness="0" 
                            FontSize="12" FontWeight="Bold" Cursor="Hand" ToolTip="Toggle Theme"
                            Style="{StaticResource {x:Type Button}}"/>
                    <Button x:Name="btnMinimize" Content="_" Width="30" Height="30" Margin="2" 
                            Background="Transparent" Foreground="#F0F6FC" BorderThickness="0" 
                            FontSize="14" FontWeight="Bold" Cursor="Hand" ToolTip="Minimize"
                            Style="{StaticResource {x:Type Button}}"/>
                    <Button x:Name="btnClose" Content="X" Width="30" Height="30" Margin="2" 
                            Background="Transparent" Foreground="#F0F6FC" BorderThickness="0" 
                            FontSize="12" FontWeight="Bold" Cursor="Hand" ToolTip="Close"
                            Style="{StaticResource {x:Type Button}}"/>
                </StackPanel>
            </Grid>
            
            <!-- Main Content -->
            <Grid Grid.Row="1" Margin="30,25,30,0">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

                <!-- Source Section -->
                <Border Grid.Row="0" Background="#161B22" CornerRadius="8" BorderBrush="#30363D" BorderThickness="1" Padding="20,15">
                    <StackPanel>
                        <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
                            <Rectangle Width="12" Height="12" Fill="#F85149" Margin="0,0,10,0" VerticalAlignment="Center" RadiusX="2" RadiusY="2"/>
                            <TextBlock Text="SOURCE DIRECTORY" FontWeight="Bold" FontSize="12" Foreground="#F0F6FC" VerticalAlignment="Center"/>
                        </StackPanel>
                        <Grid>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
                            <TextBox x:Name="txtSource" Grid.Column="0" Height="40" Margin="0,0,10,0"
                                     Background="#0D1117" Foreground="#F0F6FC" Padding="12,0" 
                                     BorderThickness="1" BorderBrush="#30363D" FontSize="13"
                                     VerticalContentAlignment="Center"/>
                            <Button x:Name="btnSource" Grid.Column="1" Content="Browse" Width="100" Height="40"
                                    Background="#238636" Foreground="White" BorderThickness="0" 
                                    FontWeight="SemiBold" Cursor="Hand"/>
        </Grid>
                    </StackPanel>
                </Border>
                
                <!-- Destination Section -->
                <Border Grid.Row="1" Background="#161B22" CornerRadius="8" BorderBrush="#30363D" BorderThickness="1" 
                        Padding="20,15" Margin="0,15,0,0">
                    <StackPanel>
                        <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
                            <Rectangle Width="12" Height="12" Fill="#1F6FEB" Margin="0,0,10,0" VerticalAlignment="Center" RadiusX="2" RadiusY="2"/>
                            <TextBlock Text="BACKUP DESTINATION" FontWeight="Bold" FontSize="12" Foreground="#F0F6FC" VerticalAlignment="Center"/>
                        </StackPanel>
                        <Grid>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
                            <TextBox x:Name="txtDest" Grid.Column="0" Height="40" Margin="0,0,10,0"
                                     Background="#0D1117" Foreground="#F0F6FC" Padding="12,0" 
                                     BorderThickness="1" BorderBrush="#30363D" FontSize="13"
                                     VerticalContentAlignment="Center"/>
                            <Button x:Name="btnDest" Grid.Column="1" Content="Browse" Width="100" Height="40"
                                    Background="#238636" Foreground="White" BorderThickness="0" 
                                    FontWeight="SemiBold" Cursor="Hand"/>
        </Grid>
                    </StackPanel>
                </Border>
                
                <!-- Schedule Section -->
                <Border Grid.Row="2" Background="#161B22" CornerRadius="8" BorderBrush="#30363D" BorderThickness="1" 
                        Padding="20,15" Margin="0,15,0,0">
                    <StackPanel>
                        <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
                            <Rectangle Width="12" Height="12" Fill="#F0C674" Margin="0,0,10,0" VerticalAlignment="Center" RadiusX="2" RadiusY="2"/>
                            <TextBlock Text="SCHEDULE SETTINGS" FontWeight="Bold" FontSize="12" Foreground="#F0F6FC" VerticalAlignment="Center"/>
                        </StackPanel>
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="120"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <TextBlock Grid.Column="0" Text="Daily backup at:" VerticalAlignment="Center" Margin="0,0,10,0" 
                                       Foreground="#7D8590"/>
                            <TextBox x:Name="txtTime" Grid.Column="1" Height="40" Text="23:00" 
                                     Background="#0D1117" Foreground="#F0F6FC" Padding="12,0" 
                                     BorderThickness="1" BorderBrush="#30363D" FontSize="13"
                                     VerticalContentAlignment="Center" TextAlignment="Center"/>
                            <TextBlock Grid.Column="2" Text="(24-hour format)" VerticalAlignment="Center" Margin="10,0,0,0" 
                                       Foreground="#7D8590" FontSize="11"/>
                        </Grid>
                    </StackPanel>
                </Border>
                
                <!-- Action Buttons -->
                <Border Grid.Row="3" Background="#161B22" CornerRadius="8" BorderBrush="#30363D" BorderThickness="1" 
                        Padding="20,15" Margin="0,25,0,0">
                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                        <Button x:Name="btnSchedule" Content="Schedule Backup" Width="180" Height="45" Margin="10,0"
                                Background="#1F6FEB" Foreground="White" BorderThickness="0" 
                                FontWeight="SemiBold" FontSize="13" Cursor="Hand"/>
                        <Button x:Name="btnRunNow" Content="Run Now" Width="140" Height="45" Margin="10,0"
                                Background="#F85149" Foreground="White" BorderThickness="0" 
                                FontWeight="SemiBold" FontSize="13" Cursor="Hand"/>
                    </StackPanel>
                </Border>

                <!-- Status Section -->
                <Border Grid.Row="4" Background="#0D1117" CornerRadius="8" BorderBrush="#30363D" BorderThickness="1" 
                        Padding="20,15" Margin="0,20,0,0">
                    <StackPanel>
                        <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
                            <Ellipse x:Name="statusIndicator" Width="8" Height="8" Fill="#7D8590" Margin="0,0,8,0" VerticalAlignment="Center"/>
                            <TextBlock Text="System Status" FontWeight="SemiBold" FontSize="14" Foreground="#F0F6FC"/>
                        </StackPanel>
                        <TextBlock x:Name="lblStatus" Text="Ready to backup" Foreground="#7D8590" FontSize="12" TextWrapping="Wrap"/>
                        <ProgressBar x:Name="progressBar" Height="4" Margin="0,10,0,0" Background="#21262D" 
                                     Foreground="#238636" Visibility="Collapsed"/>
                    </StackPanel>
                </Border>
                
                <!-- Info Panel -->
                <Border Grid.Row="5" Background="#0D1117" CornerRadius="8" BorderBrush="#30363D" BorderThickness="1" 
                        Padding="20,15" Margin="0,15,0,0">
                    <StackPanel>
                        <TextBlock Text="Backup Information" FontWeight="SemiBold" FontSize="12" Foreground="#F0F6FC" Margin="0,0,0,8"/>
                        <TextBlock TextWrapping="Wrap" FontSize="11" Foreground="#7D8590">
                            <Run Text="• Backups are compressed as ZIP files with timestamp"/>
                            <LineBreak/>
                            <Run Text="• Old backups (3+ days) are automatically cleaned up"/>
                            <LineBreak/>
                            <Run Text="• Scheduled backups run daily at the specified time"/>
                        </TextBlock>
        </StackPanel>
                </Border>
            </Grid>
            
            <!-- Footer -->
            <Border Grid.Row="2" Background="#21262D" BorderBrush="#30363D" BorderThickness="0,1,0,0">
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,20,0">
                    <TextBlock Text="v2.0 Professional" FontSize="11" Foreground="#7D8590" VerticalAlignment="Center"/>
                </StackPanel>
            </Border>
    </Grid>
    </Border>
</Window>
"@

# Load XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Add modern styling and animations
Add-Type -AssemblyName PresentationFramework

# Link controls
$txtSource        = $Window.FindName("txtSource")
$txtDest          = $Window.FindName("txtDest")
$txtTime          = $Window.FindName("txtTime")
$btnSource        = $Window.FindName("btnSource")
$btnDest          = $Window.FindName("btnDest")
$btnRunNow        = $Window.FindName("btnRunNow")
$btnSchedule      = $Window.FindName("btnSchedule")
$lblStatus        = $Window.FindName("lblStatus")
$statusIndicator  = $Window.FindName("statusIndicator")
$progressBar      = $Window.FindName("progressBar")
$btnMinimize      = $Window.FindName("btnMinimize")
$btnClose         = $Window.FindName("btnClose")
$btnTheme         = $Window.FindName("btnTheme")

# Theme switching variables
$isDarkTheme = $true

# Theme switching function
function Switch-Theme {
    if ($isDarkTheme) {
        # Switch to light theme
        $Window.Background = "#FFFFFF"
        $Window.Foreground = "#000000"
        $btnTheme.Content = "L"
        $isDarkTheme = $false
        Show-Notification -Title "Theme Changed" -Message "Switched to light theme" -Type "Info"
    } else {
        # Switch to dark theme
        $Window.Background = "#0D1117"
        $Window.Foreground = "#F0F6FC"
        $btnTheme.Content = "L"
        $isDarkTheme = $true
        Show-Notification -Title "Theme Changed" -Message "Switched to dark theme" -Type "Info"
    }
}

# Window Controls with hover effects
$btnTheme.Add_Click({
    Switch-Theme
})
$btnTheme.Add_MouseEnter({
    $btnTheme.Background = "#30363D"
})
$btnTheme.Add_MouseLeave({
    $btnTheme.Background = "Transparent"
})

$btnMinimize.Add_Click({
    $Window.WindowState = "Minimized"
})
$btnMinimize.Add_MouseEnter({
    $btnMinimize.Background = "#30363D"
})
$btnMinimize.Add_MouseLeave({
    $btnMinimize.Background = "Transparent"
})

$btnClose.Add_Click({
    $tray.Visible = $false
    $Window.Close()
})
$btnClose.Add_MouseEnter({
    $btnClose.Background = "#F85149"
})
$btnClose.Add_MouseLeave({
    $btnClose.Background = "Transparent"
})

# Make window draggable
$Window.Add_MouseLeftButtonDown({
    $Window.DragMove()
})

# Folder pickers with enhanced UI feedback
$btnSource.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select source folder to backup"
    if ($dialog.ShowDialog() -eq "OK") { 
        $txtSource.Text = $dialog.SelectedPath
        Update-StatusIndicator "ready"
    }
})
$btnDest.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select backup destination folder"
    if ($dialog.ShowDialog() -eq "OK") { 
        $txtDest.Text = $dialog.SelectedPath
        Update-StatusIndicator "ready"
    }
})

# Run Now with enhanced validation
$btnRunNow.Add_Click({
    if ($txtSource.Text -and $txtDest.Text) {
        if (Test-Path $txtSource.Text) {
        Start-Backup -Source $txtSource.Text -Dest $txtDest.Text
        } else {
            Update-StatusIndicator "error"
            [System.Windows.MessageBox]::Show("Source path does not exist: $($txtSource.Text)", "Invalid Path", "OK", "Error")
        }
    }
    else {
        [System.Windows.MessageBox]::Show("Please select both Source and Destination folders first.", "Missing Information", "OK", "Warning")
    }
})

# Schedule with enhanced feedback
$btnSchedule.Add_Click({
    if ($txtSource.Text -and $txtDest.Text) {
        try {
    $jobScript = {
        param($s,$d)
                Start-Backup -Source $s -Dest $d
    }
            
    # Remove existing job if it exists
if (Get-ScheduledJob -Name "AutoBackupJob" -ErrorAction SilentlyContinue) {
    Unregister-ScheduledJob -Name "AutoBackupJob" -Confirm:$false
}

# Register new job
Register-ScheduledJob -Name "AutoBackupJob" -ScriptBlock $jobScript -ArgumentList $txtSource.Text,$txtDest.Text -Trigger (New-JobTrigger -Daily -At $txtTime.Text)

            $lblStatus.Text = "Backup scheduled daily at $($txtTime.Text)"
            $lblStatus.Foreground = "#1F6FEB"
            $statusIndicator.Fill = "#1F6FEB"
            
            Show-Notification -Title "Backup Scheduled" -Message "Daily backup scheduled at $($txtTime.Text)" -Type "Info"
        }
        catch {
            Update-StatusIndicator "error"
            [System.Windows.MessageBox]::Show("Failed to schedule backup: $($_.Exception.Message)", "Scheduling Error", "OK", "Error")
        }
    }
    else {
        [System.Windows.MessageBox]::Show("Please select both Source and Destination folders first.", "Missing Information", "OK", "Warning")
    }
})

# ---------- ENHANCED TRAY ICON ----------
$tray = New-Object System.Windows.Forms.NotifyIcon
$tray.Icon = [System.Drawing.SystemIcons]::Application
$tray.Visible = $true
$tray.Text = "Pro Backup Manager"

# Enhanced tray menu
$menu = New-Object System.Windows.Forms.ContextMenu
$showItem = New-Object System.Windows.Forms.MenuItem "Show Window"
$showItem.add_Click({
    $Window.WindowState = "Normal"
    $Window.Activate()
})
$menu.MenuItems.Add($showItem)

$menu.MenuItems.Add("-") # Separator

$runNowItem = New-Object System.Windows.Forms.MenuItem "Run Backup Now"
$runNowItem.add_Click({
    if ($txtSource.Text -and $txtDest.Text) {
        if (Test-Path $txtSource.Text) {
            Start-Backup -Source $txtSource.Text -Dest $txtDest.Text
        }
    }
})
$menu.MenuItems.Add($runNowItem)

$menu.MenuItems.Add("-") # Separator

$exitItem = New-Object System.Windows.Forms.MenuItem "Exit"
$exitItem.add_Click({
    $tray.Visible = $false
    $Window.Close()
})
$menu.MenuItems.Add($exitItem)
$tray.ContextMenu = $menu

# Double-click to show window
$tray.add_DoubleClick({
    $Window.WindowState = "Normal"
    $Window.Activate()
})

# Window state change handling
$Window.add_StateChanged({
    if ($Window.WindowState -eq "Minimized") {
        $Window.Hide()
        Show-Notification -Title "Pro Backup Manager" -Message "Minimized to system tray" -Type "Info"
    }
})

# Startup animation and welcome message
$Window.Opacity = 0

# Show welcome notification
Show-Notification -Title "Pro Backup Manager" -Message "Welcome! Professional backup solution loaded successfully." -Type "Info"

# Fade in animation
$fadeIn = New-Object System.Windows.Media.Animation.DoubleAnimation
$fadeIn.From = 0
$fadeIn.To = 1
$fadeIn.Duration = [System.Windows.Duration]::new([System.TimeSpan]::FromMilliseconds(500))
$Window.BeginAnimation([System.Windows.Window]::OpacityProperty, $fadeIn)

# Run window
$Window.ShowDialog() | Out-Null
