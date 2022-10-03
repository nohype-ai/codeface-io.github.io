import Foundation
import SwiftyToolz

func generateStandardPage(inFolderPath folderPath: String,
                          withRootPath rootPath: String,
                          metaData: PageMetaData = .codeface(),
                          pageCSSFolderPath providedPageCSSFolderPath: String? = nil,
                          pageContentHTML providedPageContentHTML: String? = nil,
                          script: String = "",
                          siteFolder: SiteFolder) throws
{
    let pageCSSFolderPath = providedPageCSSFolderPath ?? "blog/"
    let pageContentHTML = try providedPageContentHTML ?? siteFolder.read(file: folderPath + "index_content.html")
    
    let pageFilePath = folderPath + "index.html"
    
    let pageHTML = generateCodefacePageHTML(rootPath: rootPath,
                                            filePathRelativeToRoot: pageFilePath,
                                            metaData: metaData,
                                            cssFiles: [rootPath + "codeface.css",
                                                       rootPath + pageCSSFolderPath + "page_style.css"],
                                            bodyContentHTML: pageContentHTML,
                                            script: script)
    
    try siteFolder.write(text: pageHTML, toFile: pageFilePath)
    log("Did write: \(pageFilePath) ✅")
}

func generateCodefacePageHTML(rootPath: String,
                              filePathRelativeToRoot: String,
                              metaData: PageMetaData = .codeface(),
                              imagePathRelativeToRoot: String? = nil,
                              cssFiles: [String] = [],
                              bodyContentHTML: String,
                              script: String = "") -> String
{
    let navBarHTML = generateNavigationBarHTML(rootPath: rootPath)
    let footerHTML = generateFooterHTML(rootPath: rootPath)
    let bodyContentHTML = navBarHTML + "\n\n" + bodyContentHTML + "\n\n" + footerHTML
    
    let rootURL = "https://codeface.io"
    let imagePath = imagePathRelativeToRoot ?? "app/icon_1024.png"
    
    let iconLinks =
    """
    <!-- Favicon (made with https://favicon.io) -->
    <link rel="apple-touch-icon" sizes="180x180" href="/favicon_io/apple-touch-icon.png">
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon_io/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/favicon_io/favicon-16x16.png">
    <link rel="manifest" href="/favicon_io/site.webmanifest">
    """
    
    return generatePageHTML(metaData: metaData,
                            imageURL: rootURL + "/" + imagePath,
                            canonicalURL: rootURL + "/" + filePathRelativeToRoot,
                            cssFiles: cssFiles,
                            otherHeadContent: iconLinks,
                            bodyContentHTML: bodyContentHTML,
                            script: script)
}

extension PageMetaData
{
    static func codeface(title: String? = nil,
                         author: String? = nil,
                         description: String? = nil,
                         keywords: String? = nil,
                         ogType: String? = nil) -> PageMetaData
    {
        .init(title: title ?? "Codeface",
              author: author ?? "Sebastian Fichtner",
              description: description ?? "See the Architecture of any Codebase",
              keywords: keywords ?? defaultKeywords,
              ogType: ogType)
    }
    
    static let defaultKeywords = "macOS, Swift, software architecture, app, codeface, codebase"
}

func generateNavigationBarHTML(rootPath: String) -> String
{
    """
    <section id="codeface-navbar" class="codeface-bar">
        <div>
            <a id="logo" class="clickable-image" href="\(rootPath)index.html">
                <img style="height:30px" src="\(rootPath)favicon_io/android-chrome-512x512.png"/>
            </a>
    
            <a class="left subtle-link" href="\(rootPath)blog/index.html">Blog</a>
                
            <a class="left subtle-link" href="\(rootPath)index.html#contact">Contact</a>
            
            <a id="call-to-action"
                href="https://apps.apple.com/app/codeface/id1578175415"
                target="_blank">
                <img style="width:180px"
                    src="\(rootPath)app/App_Store_Badge.svg"
                    title="Download Codeface for free from the Mac App Store"/>
            </a>
        </div>
    </section>
    """
}

func generateFooterHTML(rootPath: String) -> String
{
    """
    <section id="codeface-bottom-bar" class="codeface-bar">
        <div>
            <div class="bottom-bar-text-element" style="text-align: left;">
                <a href="\(rootPath)privacy-policy/index.html">
                    Codeface Privacy Policy
                </a>
                <span> • </span>
                <a href="\(rootPath)imprint/index.html">
                    Imprint
                </a>
            </div>
            
            <div style="text-align: center; padding-top: 15px; padding-bottom: 15px">
                <a href="https://github.com/codeface-io" target="_blank" style="display:block;height:32px">
                    <img src="\(rootPath)social-icons/github.svg" style="width:32px;"/>
                    <span style="vertical-align:32%; margin-left: 5px">GitHub</span>
                </a>
            </div>
    
            <div class="bottom-bar-text-element" style="text-align: right;">
                Copyright &copy; 2022 Sebastian Fichtner
            </div>
        </div>
    </section>
    """
}
