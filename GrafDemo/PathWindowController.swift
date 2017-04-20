import Cocoa

class PathWindowController: NSWindowController {
    @IBOutlet var pathSamplerView: PathSamplerView!
    
    override func windowDidLoad() {
        pathSamplerView.addSamplePath()
    }
    
    @IBAction func dumpPath(_ sender: NSButton) {
        let path = pathSamplerView.buildPath()
        path.dump()
    }
 }
