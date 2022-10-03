import FoundationToolz
import Foundation
import SwiftyToolz

func generateBlogPages(siteFolder: SiteFolder) throws
{
    try generateBlogPage(siteFolder: siteFolder)
    try generateBlogPostPages(siteFolderURL: siteFolder.url)
}

private func generateBlogPage(siteFolder: SiteFolder) throws
{
    try generateStandardPage(inFolderPath: "blog/",
                             withRootPath: "../",
                             metaData: .codeface(title: "Codeface Blog", ogType: "blog"),
                             pageContentHTML: try generateBlogPageContentHTML(siteFolder: siteFolder),
                             siteFolder: siteFolder)
}

private func generateBlogPageContentHTML(siteFolder: SiteFolder) throws -> String
{
    let postsFolder = siteFolder.url + "blog/posts"
    
    let postFolders = FileManager.default.items(inDirectory: postsFolder, recursive: false)
    
    let postListHTML: String = postFolders
        .map {
            
            let metaDataFile = $0 + postMetaDataFileName
            let postMetaData = PostMetaData(from: metaDataFile)
            
            if postMetaData == nil
            {
                log(warning: "No \(postMetaDataFileName) in post folder: \($0.lastPathComponent)")
            }
            
            return ($0, postMetaData ?? .init())
        }
        .sorted {
            $0.1 < $1.1 // sort by date
        }
        .map {
            generatePostOverviewHTML(with: $1, folderName: $0.lastPathComponent)
        }
        .joined(separator: "\n\n")
    
    return """
    <section>
        <div class="blog-post-list-wrapper">
            \(postListHTML.with(newlineIndentations: 2))
        </div>
    </section>
    """
}

private func generatePostOverviewHTML(with metaData: PostMetaData, folderName: String) -> String
{
    """
    <h2><a class="subtle-link" href="posts/\(folderName)/index.html">\(metaData.title ?? defaultTitle(fromPostFolderName: folderName))</a></h2>
    
    <div class="blog-post-grid">
        <a href="posts/\(folderName)/index.html">
            <img class="blog-post-image" src="posts/\(folderName)/\(metaData.posterImage ?? "images/poster.png")"></img>
        </a>
    
        <div>
            <p style="margin-top:-3px;margin-bottom:-8px" class="secondary-text-color">
                \(metaData.date?.displayString ?? "")
            </p>
    
            <p>
                \(metaData.excerpt ?? "")
            </p>
        </div>
    </div>
    """
}

private func generateBlogPostPages(siteFolderURL: URL) throws
{
    let postsFolder = siteFolderURL + "blog/posts"
    
    let postFolders = FileManager.default.items(inDirectory: postsFolder,
                                                recursive: false)
    
    for postFolder in postFolders
    {
        let postContentFileName = "post_content.html"
        let postFolderName = postFolder.lastPathComponent
        
        guard let postContentHTML = try? (postFolder + postContentFileName).readText() else
        {
            log(error: "Couldn't read \(postContentFileName) in post folder: \(postFolderName)")
            continue
        }
        
        let postMetaDataFile = postFolder + postMetaDataFileName
        let postMetaData = PostMetaData(from: postMetaDataFile)
        
        if postMetaData == nil
        {
            log(warning: "No \(postMetaDataFileName) in post folder: \(postFolderName)")
        }
        
        let title = postMetaData?.title ?? defaultTitle(fromPostFolderName: postFolderName)
        let date = postMetaData?.date?.displayString ?? ""
        let author = postMetaData?.author ?? "Sebastian Fichtner"
        let dateAndAuthor = date + " • " + author
        
        let postPageBodyContentHTML =
        """
        <section>
            <div>
                <h1 style="margin-bottom:30px">\(title)</h1>
        
                <p style="text-align:center" class="secondary-text-color">
                    \(dateAndAuthor)
                </p>
        
                \(postContentHTML.with(newlineIndentations: 2))
            </div>
        </section>
        """
        
        let postFolderPath = "blog/posts/" + postFolderName
        
        let postImagePath: String? = {
            guard let posterImage = postMetaData?.posterImage else { return nil }
            return postFolderPath + "/" + posterImage
        }()
        
        let postFileName = "index.html"
        
        let postPageHTML = generateCodefacePageHTML(rootPath: "../../../",
                                                    filePathRelativeToRoot: postFolderPath + "/" + postFileName,
                                                    metaData: .codeface(title: title,
                                                                        author: author,
                                                                        description: postMetaData?.excerpt,
                                                                        keywords: postMetaData?.keywords,
                                                                        ogType: "article"),
                                                    imagePathRelativeToRoot: postImagePath,
                                                    cssFiles: ["../../../codeface.css", "../../page_style.css"],
                                                    bodyContentHTML: postPageBodyContentHTML)
        
        try (postFolder + postFileName).write(text: postPageHTML)
        log("Did write: \(postFolderName)/\(postFileName) ✅")
    }
}

private func defaultTitle(fromPostFolderName folderName: String) -> String
{
    folderName
        .replacingOccurrences(of: "-", with: " ")
        .capitalized
}

private var postMetaDataFileName: String { "post_meta_data.json" }
