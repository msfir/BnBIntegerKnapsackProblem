import Foundation

struct Item {
    let name: String
    let weight: Int
    let profit: Int
    
    func ratio() -> Double {
        return Double(self.profit) / Double(self.weight)
    }
}

typealias KnapsackNode = [Item]

extension Array where Element == Item {
    func weight() -> Int {
        return self.reduce(0) { $0 + $1.weight }
    }
    func profit() -> Int {
        return self.reduce(0) { $0 + $1.profit }
    }
    func getBound(node: KnapsackNode, maxWeight: Int) -> Double {
        if (node.weight() >= maxWeight) {
            return 0.0
        }
        var remWeight = maxWeight - node.weight()
        var bound = Double(node.profit())
        var i = node.count
        while (i < self.count && remWeight >= self[i].weight) {
            remWeight -= self[i].weight
            bound += Double(self[i].profit)
            i += 1
        }
        if (i < self.count) {
                bound += Double(remWeight) * self[i].ratio()
        }
        return bound
    }
 }

func knapsack(items: KnapsackNode, capacity: Int) -> KnapsackNode {
    let sortedItems = items.sorted() { $0.ratio() < $1.ratio() }
    var maxProfit = 0
    var queue = [(0, Array<Item>())]
    var result = Array<Item>()
    
    while !queue.isEmpty {
        // print(queue)
        let (level, node) = queue.removeFirst()
        
        if (level == sortedItems.count) {
            continue
        }
        
        let v = node + [sortedItems[level]]
        // print(v)
        if (v.weight() <= capacity && v.profit() > maxProfit) {
            maxProfit = v.profit()
            result = v
        }
        if (items.getBound(node: v, maxWeight: capacity) > Double(maxProfit)) {
            queue.append((level + 1, v))
        }
        if (items.getBound(node: node, maxWeight: capacity) > Double(maxProfit)) {
            queue.append((level + 1, node))
        }
        
    }
    
    return result.sorted { $0.name < $1.name }
}

func getIntegerInput(_ question: String) -> Int {
    var result: Int? = nil
    while true {
        print(question, terminator: "")
        let input = readLine()
        result = input != nil ? Int(input!.trimmingCharacters(in: .whitespacesAndNewlines)) : nil
        if (result == nil) {
            print("Masukan tidak valid!")
            continue
        }
        break
    }
    return result!
}

func printItemsTable(_ items: [Item]) {
    let totalWeight = String(items.reduce(0, { $0 + $1.weight }))
    let totalProfit = String(items.reduce(0, { $0 + $1.profit }))

    let indexColumnWidth = String(items.count).count
    let nameColumnWidth = max(5, items.map { $0.name.count }.max() ?? 0)
    let weightColumnWidth = max(5, items.map { String($0.weight).count }.max() ?? 0, totalWeight.count)
    let profitColumnWidth = max(6, items.map { String($0.profit).count }.max() ?? 0, totalProfit.count)
    
    let indexLine = String(repeating: "─", count: indexColumnWidth + 2)
    let nameLine = String(repeating: "─", count: nameColumnWidth + 2)
    let weightLine = String(repeating: "─", count: weightColumnWidth + 2)
    let profitLine = String(repeating: "─", count: profitColumnWidth + 2)
    
    let top    = "┌\(indexLine)┬\(nameLine)┬\(weightLine)┬\(profitLine)┐"
    let center = "├\(indexLine)┼\(nameLine)┼\(weightLine)┼\(profitLine)┤"
    let bottom = "└\(indexLine)┴\(nameLine)┴\(weightLine)┴\(profitLine)┘"
    
    let column: (String, Int) -> String = { s, w in s.padding(toLength: w, withPad: " ", startingAt: 0) }
    let row: (String, String, String, String) -> String = { a, b, c, d in
        "│ \(column(a, indexColumnWidth)) │ \(column(b, nameColumnWidth)) │ \(column(c, weightColumnWidth)) │ \(column(d, profitColumnWidth)) │"
    }
    
    print(top)
    print(row("#", "Nama", "Berat", "Profit"))
    print(center)
    for i in 0...items.count-1 {
        let item = items[i]
        let index = String(i + 1)
        let name = item.name
        let weight = String(item.weight)
        let profit = String(item.profit)
        
        print(row(index, name, weight, profit))
        print(center)
    }
    print(row("#", "Total", totalWeight, totalProfit))
    print(bottom)
}

let capacity = getIntegerInput("Berapa kapasitas berat ranselmu? ")
let n = getIntegerInput("Berapa banyak barang yang kamu punya? ")
var items = Array<Item>()

for i in 1...n {
    print("===== Item ke-\(i) =====")
    print("Nama: ", terminator: "")
    let name = readLine() ?? "item\(i)"
    let weight = getIntegerInput("Berat: ")
    let profit = getIntegerInput("Profit: ")
    items.append(Item(name: name, weight: weight, profit: profit))
}

print()
print("Daftar barang yang kamu punya: ")
printItemsTable(items)
let result = knapsack(items: items, capacity: capacity)
print()
print("Daftar barang terbaik untuk dibawa: ")
printItemsTable(result)
