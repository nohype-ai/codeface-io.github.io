import Foundation
import SwiftyToolz

@main
public struct SiteGenerator
{
    public static func main()
    {
        do
        {
            let siteFolderPath = "/Users/seb/Desktop/GitHub Repos/codeface-io.github.io"
            let siteFolder = try SiteFolder(path: siteFolderPath)
            
            try generateRootPage(siteFolder: siteFolder)
            try generateDocumentationPage(siteFolder: siteFolder)
            try generatePrivacyPage(siteFolder: siteFolder)
            try generateImprintPage(siteFolder: siteFolder)
            try generateBlogPages(siteFolder: siteFolder)
        }
        catch
        {
            log(error: error.localizedDescription)
        }
    }
}
