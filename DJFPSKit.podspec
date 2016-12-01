 Pod::Spec.new do |s| 
    s.name = "DJFPSKit" 
    s.version = "0.0.1" 
    s.summary = "The easiest way to measure app's fps value" 
    s.homepage = "hhttps://github.com/ldhlfzysys/DJFPSKit" 
    s.license = "MIT" 
    s.author = { "Dwight" => "ldhlfzysys@163.com" } 
    s.social_media_url ="http://weibo.com/u/1788868134" 
    s.platform = :ios, "7.0"  
    s.source = { :git => "https://github.com/ldhlfzysys/DJFPSKit.git", :tag => "0.0.1" } 
    s.source_files  = "Classes", "Classes/**/*.{h,m}"
    s.requires_arc = true  
end