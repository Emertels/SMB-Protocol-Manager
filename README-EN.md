# SMB Protocol Manager

**Version:** 1.0.0  
**Interface languages:** Brazilian Portuguese, English, Spanish, French, German, Italian, Japanese, Korean, Simplified Chinese, and Russian. Language follows Windows UI culture; Brazilian Portuguese is the fallback.

## What it does

Inspect and manage SMB protocol and server settings on Windows.

## Files

SMB-Protocol-Manager.ps1 and Session-Header.ps1

## Usage

1. Download or clone the complete repository.
2. Run `SMB-Protocol-Manager.ps1 and Session-Header.ps1` in Windows PowerShell. Approve the UAC prompt when requested.

## Requirements

Windows 10 or Windows 11, Windows PowerShell 5.1, and administrator privileges. SMB cmdlets depend on features available in your Windows edition.

## Safety and limitations

The project must not remove personal data, credentials, or content outside paths defined by the tool. Command and feature availability depends on Windows edition and version. Review CHANGELOG.md before updating.

## Development

See AGENTS-PT-BR.md and AGENTS-EN.md. The default interface language follows Windows UI culture; Brazilian Portuguese is the fallback.

## Languages, purpose, and tips

Menus, confirmations, status labels, and tool messages are translated into all ten languages. Error details supplied by Windows may use the system language.

SMBv1 is legacy and vulnerable: keep it disabled and enable it only temporarily on a controlled network for legacy equipment. Enabling it requires typed confirmation. Changes may require a restart.

### Idiomas disponíveis / Available languages

| Language | Locale | Used for |
|---|---|---|
| Brazilian Portuguese | pt-BR | Brazilian Windows; fallback for unsupported locales |
| English | en | English Windows |
| Spanish | es | Spanish Windows |
| French | fr | French Windows |
| German | de | German Windows |
| Italian | it | Italian Windows |
| Japanese | ja | Japanese Windows |
| Korean | ko | Korean Windows |
| Simplified Chinese | zh-CN | Simplified Chinese Windows |
| Russian | ru | Russian Windows |







## About Emerson Teles

Emerson Teles (Emertels) builds Windows tools for automation, emulation, and software localization. Explore his projects and official channels:

- [Official website](https://emertels.github.io) · [GitHub](https://github.com/Emertels) · [Discord](https://emertels.github.io/discord)
- [YouTube](https://www.youtube.com/@emersonteles2379) · [X](https://x.com/emertels) · [Telegram](https://t.me/apksmodsandroid) · [Ko-fi](https://ko-fi.com/emertels)

### Other projects

- [AI-Chat-Vault](https://github.com/Emertels/AI-Chat-Vault) — portable backup and recovery for local AI assistant conversations.
- [Suite-Emuladores](https://github.com/Emertels/Suite-Emuladores) — Windows download and update management for emulators and frontends.
- [Microsoft-Photos-Fix](https://github.com/Emertels/Microsoft-Photos-Fix) — startup and wallpaper fixes for the Windows Photos app.
- [PSBBN-Translator](https://github.com/Emertels/PSBBN-Translator) — localization of the PSBBN Definitive Project into 40 languages.
- [GPU-Tweak-III-Traducao-PTBR](https://github.com/Emertels/GPU-Tweak-III-Traducao-PTBR), [Cursor-Traducao-PTBR](https://github.com/Emertels/Cursor-Traducao-PTBR), [CodexRouter-Traducao-PTBR](https://github.com/Emertels/CodexRouter-Traducao-PTBR), [Antigravity-Traducao-PTBR](https://github.com/Emertels/Antigravity-Traducao-PTBR), and [ZCode-Traducao-PTBR](https://github.com/Emertels/ZCode-Traducao-PTBR) — Brazilian Portuguese localization projects.
- [Silent-Hill-Homecoming-Traducao-PTBR](https://github.com/Emertels/Silent-Hill-Homecoming-Traducao-PTBR) — PC translation and review project.



