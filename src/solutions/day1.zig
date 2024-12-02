const std = @import("std");

const ArrayList = std.ArrayList;
const assert = std.debug.assert;
const expect = std.testing.expect;

pub fn dataFromFile() !struct { left_list: []u32, right_list: []u32 } {
    var file = try std.fs.cwd().openFile("src/solutions/day1.txt", .{});
    defer file.close();

    // Allocate arrays that will be used to store left and right lists
    const allocator = std.heap.page_allocator;
    var left_list = ArrayList(u32).init(allocator);
    var right_list = ArrayList(u32).init(allocator);

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [256]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.splitSequence(u8, line, "   ");
        while (it.next()) |x| {
            const numb = try std.fmt.parseUnsigned(u32, x, 10);
            if (it.index == null) {
                try right_list.append(numb);
            } else {
                try left_list.append(numb);
            }
        }
    }

    return .{
        .left_list = left_list.items,
        .right_list = right_list.items,
    };
}

pub fn solution(left_list: []u32, right_list: []u32) !struct { part1: u32, part2: u32 } {
    assert(left_list.len == right_list.len);

    std.mem.sort(u32, left_list, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, right_list, {}, comptime std.sort.asc(u32));

    return .{
        .part1 = part1Solution(left_list, right_list),
        .part2 = try part2Solution(left_list, right_list),
    };
}

fn part1Solution(left_list: []u32, right_list: []u32) u32 {
    var sum: u32 = 0;

    for (0..left_list.len) |i| {
        // To avoid integer overflow :/
        if (left_list[i] < right_list[i]) {
            sum += right_list[i] - left_list[i];
        } else {
            sum += left_list[i] - right_list[i];
        }
    }

    return sum;
}

fn part2Solution(left_list: []u32, right_list: []u32) !u32 {
    const allocator = std.heap.page_allocator;
    var map = std.AutoHashMap(u32, u32).init(
        allocator,
    );
    defer map.deinit();

    var counter: u32 = 0;

    for (0..left_list.len) |i| {
        counter = 0;
        const left_val = left_list[i];

        if (map.get(left_val) != undefined) {
            continue;
        }

        for (0..right_list.len) |j| {
            const right_val = right_list[j];

            if (left_val == right_val) {
                counter += 1;
            }
        }

        try map.put(left_val, counter);
    }

    var map_iterator = map.iterator();

    var res: u32 = 0;

    while (map_iterator.next()) |entry| {
        if (entry.value_ptr.* != 0) {
            res += entry.key_ptr.* * entry.value_ptr.*;
        }
    }

    return res;
}

test "test with example data" {
    var left_list = [6]u32{ 3, 4, 2, 1, 3, 3 };
    var right_list = [6]u32{ 4, 3, 5, 3, 9, 3 };

    try expect(try solution(left_list[0..], right_list[0..]) == 11);
}
