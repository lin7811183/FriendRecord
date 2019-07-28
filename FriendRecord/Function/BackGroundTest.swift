import Foundation

class BackGroundTask {
    
    private var backgroundTimer :Timer!
    private var timerCount = 0.0
    
    func starRun() {
        DispatchQueue.global(qos: .default).async {
            print("Back Ground Task Running.....")
            
            self.backgroundTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
            RunLoop.current.add(self.backgroundTimer, forMode: RunLoop.Mode.common)
            
            if (Int(self.timerCount) % 5) == 0 {
                print("BackGround Timer is checking.....")
            }
        }
    }
    
    @objc func updateTimer() {
        self.timerCount = self.timerCount + 0.1
        print(self.timerCount)
    }
}

