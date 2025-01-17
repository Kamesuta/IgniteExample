﻿# pluginsディレクトリに最新のプラグインをコピーするスクリプト
$ErrorActionPreference = "Stop"

Write-Host "-> Start Copying..."

# 現在のディレクトリを設定 (プロジェクトルート = .runの一つ上のディレクトリ)
Set-Location $(Split-Path $PSScriptRoot -Parent)

# プラグインのディレクトリを作成
New-Item -ItemType Directory -Force -Path "run\plugins" | Out-Null

# Gradleの出力ディレクトリからアイテムを取得する
Get-ChildItem -Path build\libs\*.jar |
# -sources.jarや-javadoc.jarなど(-小文字)の末尾のないjarのみをコピーする
Where-Object { $_.Name -cNotMatch '-[a-z]+\.jar' } |
# 編集日でソートする
Sort-Object LastWriteTime -Descending |
# プラグイン名をオブジェクトに追加
Select-Object -Property *, @{
    Name = 'PluginName'
    Expression = {
        # 名前以外の情報(バージョン情報など)を除去する
        $pos = $_.Name.IndexOf("-")
        $_.Name.Substring(0, $pos)
    }
} |
# プラグイン名でグループ化
Group-Object -Property PluginName |
# 最新のプラグインのみを取得する
ForEach-Object { $_.Group | Select-Object -First 1 } |
# ファイルをコピーする
ForEach-Object {
    Copy-Item $_.FullName -Destination run\mods\$($_.PluginName).jar -Force
    Write-Host "~ build\libs\$($_.Name) -> run\mods\$($_.PluginName).jar"
}

Write-Host "-> Done!"
