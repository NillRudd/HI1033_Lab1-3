    //
    //  BluetoothConnect.swift
    //  HI1033_Lab1-3
    //
    //  Created by Niklas Roslund on 2023-12-11.
    //

    import Foundation
    import CoreBluetooth

    protocol BluetoothConnectDelegate: AnyObject {
        func bluetoothConnectDidDiscoverPeripheral(_ peripheral: CBPeripheral)
        func retriveSensorAccData(xSample: Double, ySample: Double, zSample: Double)
        func retriveSensorGyroData(xSample: Double, ySample: Double, zSample: Double)
        func filterBoth()
    }

    class BluetoothConnect: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
        weak var delegate: BluetoothConnectDelegate?
        var centralManager: CBCentralManager!
        var peripheralBLE: CBPeripheral!
        var bluetoothDevices : [CBPeripheral] = []
        var commandCharacteristic: CBCharacteristic?
        
        let GATTService = CBUUID(string: "fb005c80-02e7-f387-1cad-8acd2d8df0c8")
        let GATTCommand = CBUUID(string: "fb005c81-02e7-f387-1cad-8acd2d8df0c8")
        let GATTData = CBUUID(string: "fb005c82-02e7-f387-1cad-8acd2d8df0c8")
        
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state {
              case .unknown:
                print("central.state is .unknown")
              case .resetting:
                print("central.state is .resetting")
              case .unsupported:
                print("central.state is .unsupported")
              case .unauthorized:
                print("central.state is .unauthorized")
              case .poweredOff:
                print("central.state is .poweredOff")
              case .poweredOn:
                print("central.state is .poweredOn")
                centralManager.scanForPeripherals(withServices: nil)
            @unknown default:
                print("unknown")
            }
        }
        
        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            print("didDiscover")
            
            if let name = peripheral.name, name.contains("Polar"){
                /*
                print("Found Polar")
                peripheralBLE = peripheral
                peripheralBLE.delegate = self
                centralManager.connect(peripheralBLE)
                central.stopScan()
                */
                if !bluetoothDevices.contains(peripheral) {
                    bluetoothDevices.append(peripheral)
                    delegate?.bluetoothConnectDidDiscoverPeripheral(peripheral)
                }
                
            }
        }
        
        func getBlueToothDevices() -> [CBPeripheral] {
            return bluetoothDevices
        }
        
        func choosePeriferal(_ peripheral: CBPeripheral){
            print("Found Polar")
            DispatchQueue.main.async {
                
                self.peripheralBLE = peripheral
                self.peripheralBLE.delegate = self
                self.centralManager.connect(self.peripheralBLE)
                self.centralManager.stopScan()
                self.bluetoothDevices = []
            }
        }
        
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
                print("didConnect")
               peripheral.discoverServices(nil)
               central.scanForPeripherals(withServices: [GATTService], options: nil)
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
             for service in peripheral.services!{
                 print("Service Found")
                 peripheral.discoverCharacteristics([GATTData, GATTCommand], for: service)
             }
         }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            print("didDiscoverCharacteristics")
            guard let characteristics = service.characteristics else { return }
            
            for characteristic in characteristics {
                if characteristic.uuid == GATTData {
                    print("Data")
                    peripheral.setNotifyValue(true, for:characteristic)
                }
                if characteristic.uuid == GATTCommand{
                    print("Command")
                    DispatchQueue.main.async {
                        self.commandCharacteristic = characteristic
                    }
                }
            }
        }
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                        error: Error?) {
            DispatchQueue.main.async {
            print("New data")
            let data = characteristic.value
            var byteArray: [UInt8] = []
            for i in data! {
                let n : UInt8 = i
                byteArray.append(n)
            }
            
            //print(byteArray)
            
            var offset = 0
            let measId = data![offset]
            offset += 1
            
            let timeBytes = data!.subdata(in: 1..<9) as NSData
            var timeStamp: UInt64 = 0
            memcpy(&timeStamp,timeBytes.bytes,8)
            offset += 8
            
            let frameType = data![offset]
            offset += 1
        
            print("MessageID:\(measId) Time:\(timeStamp) Frame Type:\(frameType)")
            
            
            let xBytes = data!.subdata(in: offset..<offset+2) as NSData
            var xSample: Int16 = 0
            memcpy(&xSample,xBytes.bytes,2)
            offset += 2
            
            let yBytes = data!.subdata(in: offset..<offset+2) as NSData
            var ySample: Int16 = 0
            memcpy(&ySample,yBytes.bytes,2)
            offset += 2
            
            let zBytes = data!.subdata(in: offset..<offset+2) as NSData
            var zSample: Int16 = 0
            memcpy(&zSample,zBytes.bytes,2)
            offset += 2
            
            print("\(measId)xRef:\(xSample >> 11) yRef:\(ySample >> 11) zRef:\(zSample >> 11)")
            
            let deltaSize = UInt16(data![offset])
            offset += 1
            let sampleCount = UInt16(data![offset])
            offset += 1
            
            //print("\(measId)deltaSize:\(deltaSize) Sample Count:\(sampleCount)")

            let bitLength = (sampleCount*deltaSize*UInt16(3))
            let length = Int(ceil(Double(bitLength)/8.0))
            let frame = data!.subdata(in: offset..<(offset+length))

            let deltas = BluetoothConnect.parseDeltaFrame(frame, channels: UInt16(3), bitWidth: deltaSize, totalBitLength: bitLength)
            
            deltas.forEach { (delta) in
                xSample = xSample + delta[0];
                ySample = ySample + delta[1];
                zSample = zSample + delta[2];
                
                //print("\(measId)xDelta:\(Double(xSample)) yDelta:\(Double(ySample)) zDelta:\(Double(zSample))")
                
                
                    
                    if(measId == 2){
                        self.delegate?.retriveSensorAccData(xSample: Double(xSample), ySample: Double(ySample), zSample: Double(zSample))
                    }
                    
                    else if(measId == 5){
                        
                        self.delegate?.retriveSensorGyroData(xSample: Double(xSample)/16.384, ySample: Double(ySample)/16.384, zSample: Double(zSample)/16.384)
                        
                        //print("\(measId)xDelta:\(Double(xSample)/16.384/52) yDelta:\(Double(ySample)/16.384/52) zDelta:\(Double(zSample)/16.384/52)")
                        
                    }
                    
                    //self.delegate?.filterBoth()
                }
            }
        }
        
       
        static func parseDeltaFrame(_ data: Data, channels: UInt16, bitWidth: UInt16, totalBitLength: UInt16) -> [[Int16]]{
            // convert array to bits
            let dataInBits = data.flatMap { (byte) -> [Bool] in
                return Array(stride(from: 0, to: 8, by: 1).map { (index) -> Bool in
                    return (byte & (0x01 << index)) != 0
                })
            }
            
            let mask = Int16.max << Int16(bitWidth-1)
            let channelBitsLength = bitWidth*channels
            
            return Array(stride(from: 0, to: totalBitLength, by: UInt16.Stride(channelBitsLength)).map { (start) -> [Int16] in
                return Array(stride(from: start, to: UInt16(start+UInt16(channelBitsLength)), by: UInt16.Stride(bitWidth)).map { (subStart) -> Int16 in
                    let deltaSampleList: ArraySlice<Bool> = dataInBits[Int(subStart)..<Int(subStart+UInt16(bitWidth))]
                    var deltaSample: Int16 = 0
                    var i=0
                    deltaSampleList.forEach { (bitValue) in
                        let bit = Int16(bitValue ? 1 : 0)
                        deltaSample |= (bit << i)
                        i += 1
                    }
                    
                    if((deltaSample & mask) != 0) {
                        deltaSample |= mask;
                    }
                    return deltaSample
                })
            })
        }
        
        override init(){
            super.init()
        }
        
        func start(){
            print("centralManager")
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        
        func startData(){
            //let parameter:[UInt8]  = [0x02, 0x00, 0x00, 0x01, 0x82, 0x00, 0x01, 0x01, 0x0E, 0x00]
            
            let parameterAcc:[UInt8]  = [0x02, 0x02, 0x00, 0x01, 0x34, 0x00, 0x01, 0x01, 0x10, 0x00, 0x02, 0x01, 0x08, 0x00, 0x04, 0x01, 0x03]
            
            //let parameter:[UInt8]  = [0x02, 0x02]
            
            let dataAcc = NSData(bytes: parameterAcc, length: 17)
            
            // Gyroscope
            let parameterGyro:[UInt8]  = [0x02, 0x05, 0x00, 0x01, 0x34, 0x00, 0x01, 0x01, 0x10, 0x00, 0x02, 0x01, 0xD0, 0x07, 0x04, 0x01, 0x03]
            let dataGyro = NSData(bytes: parameterGyro, length: 17)

            // dela med 16.384
            // För att få grader per sekund (dps)
            
        DispatchQueue.main.async {
                
            if let commandCharacteristic = self.commandCharacteristic {
                self.peripheralBLE.writeValue(dataAcc as Data, for: commandCharacteristic, type: CBCharacteristicWriteType.withResponse)
                self.peripheralBLE.writeValue(dataGyro as Data, for: commandCharacteristic, type: CBCharacteristicWriteType.withResponse)
            } else {
                print("Error: commandCharacteristic is nil")
            }
                
            }
        }
        
        func stopData() {
            let parameterAcc:[UInt8]  = [0x03, 0x02]
            
            let dataAcc = NSData(bytes: parameterAcc, length: 2)
            
            // Gyroscope
            let parameterGyro:[UInt8]  = [0x03, 0x05]
            let dataGyro = NSData(bytes: parameterGyro, length: 2)
    
            peripheralBLE.writeValue(dataAcc as Data, for: commandCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            peripheralBLE.writeValue(dataGyro as Data, for: commandCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            
            
        }
        
        
        func stop() {
            /*
            if(peripheralBLE2 != nil){
                centralManager.cancelPeripheralConnection(peripheralBLE2)
            }
            */
            if(peripheralBLE != nil){
                centralManager.cancelPeripheralConnection(peripheralBLE)
            }
        }
    }
