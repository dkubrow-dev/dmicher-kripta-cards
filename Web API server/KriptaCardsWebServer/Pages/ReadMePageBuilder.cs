// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 dmicher abathur kubrow
// Original project: https://github.com/dkubrow-dev/kripta-cards

using System.Net;
using Markdig;

namespace KriptaCards.WebApi.Pages;

/// <summary>
/// Строитель страницы с документацией
/// </summary>
public static class ReadmePageBuilder
{
    /// <summary>
    /// Сформировать HTML файл документации на основе README-файла в проекте
    /// </summary>
    /// <param name="markdown">Строка с разметкой MD для преобразования к HTML</param>
    /// <param name="title">Заголовок страницы HTML</param>
    /// <returns></returns>
    public static string BuildHtml(string markdown, string title = "Kripta Cards Web API")
    {
        var pipeline = new MarkdownPipelineBuilder()
            .UseAdvancedExtensions()
            .Build();

        string bodyHtml = Markdown.ToHtml(markdown, pipeline);
        string safeTitle = WebUtility.HtmlEncode(title);

        return
        $$"""
        <!DOCTYPE html>
        <html lang="ru">
        <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>{{safeTitle}}</title>
            <style>
                :root {
                    color-scheme: light dark;
                }
        
                body {
                    margin: 0;
                    font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
                    line-height: 1.6;
                    background: #111;
                    color: #eaeaea;
                }
        
                main {
                    max-width: 980px;
                    margin: 0 auto;
                    padding: 32px 20px 64px;
                }
        
                h1, h2, h3, h4 {
                    line-height: 1.25;
                    margin-top: 1.5em;
                }
        
                h1 {
                    margin-top: 0;
                }
        
                a {
                    color: #7db7ff;
                }
        
                code, pre {
                    font-family: Consolas, "Courier New", monospace;
                }
        
                code {
                    background: rgba(255,255,255,0.08);
                    padding: 0.15em 0.35em;
                    border-radius: 4px;
                }
        
                pre {
                    background: rgba(255,255,255,0.08);
                    padding: 12px;
                    border-radius: 8px;
                    overflow-x: auto;
                }
        
                table {
                    border-collapse: collapse;
                    width: 100%;
                }
        
                th, td {
                    border: 1px solid rgba(255,255,255,0.15);
                    padding: 8px 10px;
                    text-align: left;
                }
        
                blockquote {
                    border-left: 4px solid rgba(125,183,255,0.6);
                    margin-left: 0;
                    padding-left: 16px;
                    color: #cfcfcf;
                }
        
                img {
                    max-width: 100%;
                    height: auto;
                }
        
                hr {
                    border: none;
                    border-top: 1px solid rgba(255,255,255,0.15);
                    margin: 24px 0;
                }
            </style>
        </head>
        <body>
            <main>
                {{bodyHtml}}
            </main>
        </body>
        </html>
        """;
    }
}