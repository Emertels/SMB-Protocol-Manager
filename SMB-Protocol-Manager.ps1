#Requires -Version 5.1
# Gerenciador de Protocolos SMB — Version 1.0.0
. "$PSScriptRoot\Session-Header.ps1"

# ============================================
# Limpa funções antigas
# ============================================
Get-ChildItem Function: | Where-Object {
    $_.Name -match '^(Show-Menu|Detect-SMB|Enable-SMB|Disable-SMB|Show-Status|Ask-Restart)'
} | Remove-Item -Force -ErrorAction SilentlyContinue

# ============================================
# Elevação automática de UAC
# ============================================
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $elevationMessage = switch ($script:AppLanguage) {
        en { 'Requesting administrator privileges (UAC)...' }
        es { 'Solicitando privilegios de administrador (UAC)...' }
        fr { 'Demande des privilèges administrateur (UAC)...' }
        de { 'Administratorrechte werden angefordert (UAC)...' }
        it { 'Richiesta dei privilegi di amministratore (UAC)...' }
        ja { '管理者権限 (UAC) を要求しています...' }
        ko { '관리자 권한(UAC)을 요청하는 중...' }
        'zh-CN' { '正在请求管理员权限 (UAC)...' }
        ru { 'Запрос прав администратора (UAC)...' }
        default { 'Solicitando privilégios de Administrador (UAC)...' }
    }
    Write-Host $elevationMessage -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# ============================================
# Data/Hora de início da sessão
# ============================================
$ScriptStart = Get-Date

# ============================================
# Função auxiliar para mostrar status colorido
# ============================================
function Show-Status {
    param([string]$Label, [string]$Value)
    $statusLabels = @{
        'pt-BR' = @('Recurso SMBv1','Servidor SMBv1','Servidor SMBv2/SMBv3')
        en = @('SMBv1 feature','SMBv1 server','SMBv2/SMBv3 server')
        es = @('Característica SMBv1','Servidor SMBv1','Servidor SMBv2/SMBv3')
        fr = @('Fonction SMBv1','Serveur SMBv1','Serveur SMBv2/SMBv3')
        de = @('SMBv1-Feature','SMBv1-Server','SMBv2/SMBv3-Server')
        it = @('Funzionalità SMBv1','Server SMBv1','Server SMBv2/SMBv3')
        ja = @('SMBv1 機能','SMBv1 サーバー','SMBv2/SMBv3 サーバー')
        ko = @('SMBv1 기능','SMBv1 서버','SMBv2/SMBv3 서버')
        'zh-CN' = @('SMBv1 功能','SMBv1 服务器','SMBv2/SMBv3 服务器')
        ru = @('Компонент SMBv1','Сервер SMBv1','Сервер SMBv2/SMBv3')
    }
    $labels = $statusLabels[$script:AppLanguage]
    $localizedLabel = switch ($Label) {
        'SMB1Protocol' { $labels[0] }
        'EnableSMB1Protocol' { $labels[1] }
        'EnableSMB2Protocol' { $labels[2] }
        default { $Label }
    }
    Write-Host "$localizedLabel : " -NoNewline
    if ($Value -eq "Enabled" -or $Value -eq "True") {
        Write-Host $script:SmbText[3] -ForegroundColor Green
    }
    elseif ($Value -eq "Disabled" -or $Value -eq "False") {
        Write-Host $script:SmbText[4] -ForegroundColor Red
    }
    else {
        Write-Host $Value -ForegroundColor Yellow
    }
}

# ============================================
# Função para perguntar se quer reiniciar
# ============================================
function Ask-Restart {
    Write-Host ""
    $resposta = Read-Host $script:SmbText[5]
        $yesToken = switch ($script:AppLanguage) { 'en' { 'Y' } 'de' { 'J' } 'fr' { 'O' } 'ja' { 'Y' } 'ko' { 'Y' } 'zh-CN' { 'Y' } 'ru' { 'Д' } default { 'S' } }
    if ($resposta.Trim() -ieq $yesToken) {
        Write-Host $script:SmbText[6] -ForegroundColor Yellow
        Restart-Computer -Force
    }
    else {
        Write-Host $script:SmbText[7] -ForegroundColor Yellow
    }
}

$Smb1Safety = @{
'pt-BR' = @('SMBv1 é legado e inseguro. Habilite somente se um dispositivo antigo exigir.','Digite ATIVAR para confirmar','Ativação cancelada.','Ligado','Desligado','Deseja reiniciar o computador agora? (S/N)','Reiniciando o computador...','Reinício cancelado. Lembre-se de reiniciar depois.','Pressione Enter para continuar.','Falha na operação')
'en' = @('SMBv1 is legacy and insecure. Enable it only if an older device requires it.','Type ENABLE to confirm','Activation canceled.','Enabled','Disabled','Restart the computer now? (Y/N)','Restarting the computer...','Restart canceled. Remember to restart later.','Press Enter to continue.','The operation failed')
'es' = @('SMBv1 es antiguo e inseguro. Actívelo solo si lo requiere un dispositivo antiguo.','Escriba ACTIVAR para confirmar','Activación cancelada.','Activado','Desactivado','¿Desea reiniciar el equipo ahora? (S/N)','Reiniciando el equipo...','Reinicio cancelado. Recuerde reiniciar más tarde.','Pulse Enter para continuar.','La operación ha fallado')
'fr' = @('SMBv1 est ancien et non sécurisé. Activez-le uniquement si un ancien appareil le nécessite.','Saisissez ACTIVER pour confirmer','Activation annulée.','Activé','Désactivé','Redémarrer le PC maintenant ? (O/N)','Redémarrage du PC...','Redémarrage annulé. Pensez à redémarrer plus tard.','Appuyez sur Entrée pour continuer.','Échec de cette opération')
'de' = @('SMBv1 ist veraltet und unsicher. Nur aktivieren, wenn ein älteres Gerät es benötigt.','AKTIVIEREN zur Bestätigung eingeben','Aktivierung abgebrochen.','Aktiviert','Deaktiviert','Computer jetzt neu starten? (J/N)','Computer wird neu gestartet...','Neustart abgebrochen. Denken Sie an einen späteren Neustart.','Zum Fortfahren die Eingabetaste drücken.','Der Vorgang ist fehlgeschlagen')
'it' = @('SMBv1 è obsoleto e non sicuro. Attivalo solo se necessário per un dispositivo datato.','Digita ATTIVA per confermare','Attivazione annullata.','Attivato','Disattivato','Riavviare il computer ora? (S/N)','Riavvio del computer...','Riavvio annullato. Ricorda di riavviare più tardi.','Premi Invio per continuare.','Operazione non riuscita')
'ja' = @('SMBv1 は古く安全ではありません。古い機器で必要な場合のみ有効にしてください。','確認するには ENABLE と入力','有効化をキャンセルしました。','有効','無効','今すぐ PC を再起動しますか？ (Y/N)','PC を再起動しています...','再起動をキャンセルしました。後で再起動してください。','続行するには Enter キーを押してください。','操作に失敗しました')
'ko' = @('SMBv1은 오래되고 안전하지 않습니다. 구형 장치에 필요한 경우에만 활성화하세요.','확인하려면 ENABLE 입력','활성화를 취소했습니다.','사용','사용 안 함','지금 컴퓨터를 다시 시작할까요? (Y/N)','컴퓨터를 다시 시작하는 중...','다시 시작을 취소했습니다. 나중에 재부팅하세요.','계속하려면 Enter 키를 누르세요.','작업에 실패했습니다')
'zh-CN' = @('SMBv1 已过时且不安全。仅在旧设备需要时启用。','输入 ENABLE 以确认','已取消启用。','已启用','已禁用','现在重新启动计算机吗？(Y/N)','正在重新启动计算机...','已取消重启。请记得稍后重启。','按 Enter 继续。','操作失败')
'ru' = @('SMBv1 устарел и небезопасен. Включайте его только при необходимости для старого устройства.','Введите ENABLE для подтверждения','Включение отменено.','Включено','Отключено','Перезагрузить компьютер сейчас? (Д/Н)','Перезагрузка компьютера...','Перезагрузка отменена. Не забудьте перезагрузить компьютер позже.','Нажмите Enter, чтобы продолжить.','Операция не выполнена')
}
$script:SmbText = $Smb1Safety[$script:AppLanguage]
$script:SmbMenu = @{
    'pt-BR' = @('GERENCIADOR DE PROTOCOLOS SMB','SMBv1 (Recurso do Windows - Cliente e Servidor)','Controla se o Windows pode conectar e compartilhar por SMBv1','Detectar','Ver status atual','Ativar','Ligar o recurso','Desativar','Desligar o recurso','SMBv1 (Configuração do Servidor)','Controla conexões SMBv1 recebidas por este PC','SMBv2 / SMBv3 (Configuração do Servidor)','Controla conexões SMBv2/SMBv3 recebidas por este PC','Sair','Escolha uma opção','Opção inválida.','Saindo...')
    'en' = @('SMB PROTOCOL MANAGER','SMBv1 (Windows Feature - Client and Server)','Controls whether Windows can connect and share over SMBv1','Detect','View current status','Enable','Turn on the feature','Disable','Turn off the feature','SMBv1 (Server Configuration)','Controls incoming SMBv1 connections to this PC','SMBv2 / SMBv3 (Server Configuration)','Controls incoming SMBv2/SMBv3 connections to this PC','Exit','Choose an option','Invalid option.','Exiting...')
    'es' = @('ADMINISTRADOR DE PROTOCOLOS SMB','SMBv1 (Caracteristica de Windows - Cliente y servidor)','Controla si Windows puede conectarse y compartir mediante SMBv1','Detectar','Ver estado actual','Activar','Activar la caracteristica','Desactivar','Desactivar la caracteristica','SMBv1 (Configuracion del servidor)','Controla las conexiones SMBv1 entrantes a este PC','SMBv2 / SMBv3 (Configuracion del servidor)','Controla las conexiones SMBv2/SMBv3 entrantes a este PC','Salir','Elija una opcion','Opcion no valida.','Saliendo...')
    'fr' = @('GESTIONNAIRE DE PROTOCOLES SMB','SMBv1 (Fonction Windows - Client et serveur)','Determine si Windows peut se connecter et partager via SMBv1','Detecter','Voir le statut actuel','Activer','Activer la fonctionnalite','Desactiver','Desactiver la fonctionnalite','SMBv1 (Configuration du serveur)','Gere les connexions SMBv1 entrantes vers ce PC','SMBv2 / SMBv3 (Configuration du serveur)','Gere les connexions SMBv2/SMBv3 entrantes vers ce PC','Quitter','Choisissez une option','Option invalide.','Fermeture...')
    'de' = @('SMB-PROTOKOLLVERWALTUNG','SMBv1 (Windows-Feature - Client und Server)','Legt fest, ob Windows SMBv1-Verbindungen und Freigaben verwenden kann','Erkennen','Aktuellen Status anzeigen','Aktivieren','Feature einschalten','Deaktivieren','Feature ausschalten','SMBv1 (Serverkonfiguration)','Steuert eingehende SMBv1-Verbindungen zu diesem PC','SMBv2 / SMBv3 (Serverkonfiguration)','Steuert eingehende SMBv2/SMBv3-Verbindungen zu diesem PC','Beenden','Option auswaehlen','Ungueltige Option.','Wird beendet...')
    'it' = @('GESTIONE PROTOCOLLI SMB','SMBv1 (Funzionalita Windows - client e server)','Controlla se Windows puo connettersi e condividere tramite SMBv1','Rileva','Visualizza stato attuale','Attiva','Abilita la funzionalita','Disattiva','Disabilita la funzionalita','SMBv1 (Configurazione server)','Controlla le connessioni SMBv1 in ingresso a questo PC','SMBv2 / SMBv3 (Configurazione server)','Controlla le connessioni SMBv2/SMBv3 in ingresso a questo PC','Esci','Scegli un opzione','Opzione non valida.','Chiusura...')
    'ja' = @('SMB プロトコル マネージャー','SMBv1 (Windows 機能 - クライアントとサーバー)','Windows の SMBv1 接続と共有を制御します','検出','現在の状態を表示','有効化','機能を有効にする','無効化','機能を無効にする','SMBv1 (サーバー設定)','この PC への SMBv1 接続を制御します','SMBv2 / SMBv3 (サーバー設定)','この PC への SMBv2/SMBv3 接続を制御します','終了','オプションを選択','無効なオプションです。','終了します...')
    'ko' = @('SMB 프로토콜 관리자','SMBv1 (Windows 기능 - 클라이언트 및 서버)','Windows의 SMBv1 연결 및 공유를 제어합니다','감지','현재 상태 보기','사용','기능 켜기','사용 안 함','기능 끄기','SMBv1 (서버 구성)','이 PC로 들어오는 SMBv1 연결을 제어합니다','SMBv2 / SMBv3 (서버 구성)','이 PC로 들어오는 SMBv2/SMBv3 연결을 제어합니다','종료','옵션 선택','잘못된 옵션입니다.','종료 중...')
    'zh-CN' = @('SMB 协议管理器','SMBv1（Windows 功能 - 客户端和服务器）','控制 Windows 是否可以通过 SMBv1 连接和共享','检测','查看当前状态','启用','开启此功能','禁用','关闭此功能','SMBv1（服务器配置）','控制此电脑接收的 SMBv1 连接','SMBv2 / SMBv3（服务器配置）','控制此电脑接收的 SMBv2/SMBv3 连接','退出','请选择一个选项','无效选项。','正在退出...')
    'ru' = @('УПРАВЛЕНИЕ ПРОТОКОЛАМИ SMB','SMBv1 (компонент Windows - клиент и сервер)','Определяет возможность подключения и общего доступа через SMBv1','Проверить','Показать текущее состояние','Включить','Включить компонент','Отключить','Отключить компонент','SMBv1 (настройка сервера)','Управляет входящими подключениями SMBv1 к этому ПК','SMBv2 / SMBv3 (настройка сервера)','Управляет входящими подключениями SMBv2/SMBv3 к этому ПК','Выход','Выберите пункт','Неверный пункт.','Завершение...')
}

function Confirm-SMB1Enable {
    Write-Host $script:SmbText[0] -ForegroundColor Red
    $confirm = Read-Host $script:SmbText[1]
    $confirmToken = switch ($script:AppLanguage) {
        'pt-BR' { 'ATIVAR' } 'es' { 'ACTIVAR' } 'fr' { 'ACTIVER' }
        'de' { 'AKTIVIEREN' } 'it' { 'ATTIVA' } default { 'ENABLE' }
    }
    if ($confirm -cne $confirmToken) {
        Write-Host $script:SmbText[2] -ForegroundColor Yellow
        return $false
    }
    return $true
}
# ============================================
# Funções
# ============================================
function Show-Menu {
    $m = $script:SmbMenu[$script:AppLanguage]
    Clear-Host
    Write-Host "===========================================================" -ForegroundColor Cyan
    Write-Host $m[0] -ForegroundColor Cyan
    Write-Host "===========================================================" -ForegroundColor Cyan
    Show-AppSessionMetadata -Version '1.0.0' -Started $ScriptStart
    Write-Host ""

    Write-Host "--- $($m[1]) ---" -ForegroundColor Yellow
    Write-Host $m[2] -ForegroundColor White
    Write-Host "1. $($m[3]) - $($m[4])" -ForegroundColor Magenta
    Write-Host "2. $($m[5]) - $($m[6])" -ForegroundColor Green
    Write-Host "3. $($m[7]) - $($m[8])" -ForegroundColor Red
    Write-Host ""

    Write-Host "--- $($m[9]) ---" -ForegroundColor Yellow
    Write-Host $m[10] -ForegroundColor White
    Write-Host "4. $($m[3]) - $($m[4])" -ForegroundColor Magenta
    Write-Host "5. $($m[5]) - $($m[6])" -ForegroundColor Green
    Write-Host "6. $($m[7]) - $($m[8])" -ForegroundColor Red
    Write-Host ""

    Write-Host "--- $($m[11]) ---" -ForegroundColor Yellow
    Write-Host $m[12] -ForegroundColor White
    Write-Host "7. $($m[3]) - $($m[4])" -ForegroundColor Magenta
    Write-Host "8. $($m[5]) - $($m[6])" -ForegroundColor Green
    Write-Host "9. $($m[7]) - $($m[8])" -ForegroundColor Red
    Write-Host ""
    Write-Host "0. $($m[13])"
    Write-Host "===========================================================" -ForegroundColor Cyan
}

function Detect-SMB1Feature {
    try {
        $result = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction Stop
        Show-Status -Label 'SMB1Protocol' -Value $result.State
    } catch { Write-Host ($script:SmbText[9] + ': ' + $_.Exception.Message) -ForegroundColor Red }
}

function Enable-SMB1Feature {
    if (-not (Confirm-SMB1Enable)) { return }
    try {
        $ProgressPreference = 'SilentlyContinue'
        Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null
        $state = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction Stop
        Show-Status -Label 'SMB1Protocol' -Value $state.State
        Ask-Restart
    } catch { Write-Host ($script:SmbText[9] + ': ' + $_.Exception.Message) -ForegroundColor Red }
}

function Disable-SMB1Feature {
    try {
        $ProgressPreference = 'SilentlyContinue'
        Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null
        $state = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction Stop
        Show-Status -Label 'SMB1Protocol' -Value $state.State
        Ask-Restart
    } catch { Write-Host ($script:SmbText[9] + ': ' + $_.Exception.Message) -ForegroundColor Red }
}

function Detect-SMB1Server {
    try {
        $result = Get-SmbServerConfiguration -ErrorAction Stop
        Show-Status -Label 'EnableSMB1Protocol' -Value $result.EnableSMB1Protocol
    } catch { Write-Host ($script:SmbText[9] + ': ' + $_.Exception.Message) -ForegroundColor Red }
}

function Enable-SMB1Server {
    if (-not (Confirm-SMB1Enable)) { return }
    try {
        Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force -ErrorAction Stop | Out-Null
        $result = Get-SmbServerConfiguration -ErrorAction Stop
        Show-Status -Label 'EnableSMB1Protocol' -Value $result.EnableSMB1Protocol
    } catch { Write-Host ($script:SmbText[9] + ': ' + $_.Exception.Message) -ForegroundColor Red }
}

function Disable-SMB1Server {
    try {
        Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction Stop | Out-Null
        $result = Get-SmbServerConfiguration -ErrorAction Stop
        Show-Status -Label 'EnableSMB1Protocol' -Value $result.EnableSMB1Protocol
    } catch { Write-Host ($script:SmbText[9] + ': ' + $_.Exception.Message) -ForegroundColor Red }
}

function Detect-SMB2Server {
    try {
        $result = Get-SmbServerConfiguration -ErrorAction Stop
        Show-Status -Label 'EnableSMB2Protocol' -Value $result.EnableSMB2Protocol
    } catch { Write-Host ($script:SmbText[9] + ': ' + $_.Exception.Message) -ForegroundColor Red }
}

function Enable-SMB2Server {
    try {
        Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force -ErrorAction Stop | Out-Null
        $result = Get-SmbServerConfiguration -ErrorAction Stop
        Show-Status -Label 'EnableSMB2Protocol' -Value $result.EnableSMB2Protocol
    } catch { Write-Host ($script:SmbText[9] + ': ' + $_.Exception.Message) -ForegroundColor Red }
}

function Disable-SMB2Server {
    try {
        Set-SmbServerConfiguration -EnableSMB2Protocol $false -Force -ErrorAction Stop | Out-Null
        $result = Get-SmbServerConfiguration -ErrorAction Stop
        Show-Status -Label 'EnableSMB2Protocol' -Value $result.EnableSMB2Protocol
    } catch { Write-Host ($script:SmbText[9] + ': ' + $_.Exception.Message) -ForegroundColor Red }
}

# ============================================
# Loop principal
# ============================================
do {
    Show-Menu
    $choice = Read-Host $script:SmbMenu[$script:AppLanguage][14]

    switch ($choice) {
        "1" { Detect-SMB1Feature }
        "2" { Enable-SMB1Feature }
        "3" { Disable-SMB1Feature }
        "4" { Detect-SMB1Server }
        "5" { Enable-SMB1Server }
        "6" { Disable-SMB1Server }
        "7" { Detect-SMB2Server }
        "8" { Enable-SMB2Server }
        "9" { Disable-SMB2Server }
        "0" { 
            Write-Host $script:SmbMenu[$script:AppLanguage][16] -ForegroundColor Cyan
            break 
        }
        default { 
            Write-Host $script:SmbMenu[$script:AppLanguage][15] -ForegroundColor Red
        }
    }

    if ($choice -ne "0") {
        Write-Host ""
        Read-Host $script:SmbText[8] | Out-Null
    }
} while ($choice -ne "0")









