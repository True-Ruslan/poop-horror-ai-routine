class_name TestAssert
extends RefCounted

static func is_true(condition: bool, message: String) -> void:
    if not condition:
        push_error("TEST FAILED: %s" % message)
        assert(condition, message)

static func are_equal(actual: Variant, expected: Variant, message: String) -> void:
    if actual != expected:
        var details := "%s | expected=%s actual=%s" % [message, str(expected), str(actual)]
        push_error("TEST FAILED: %s" % details)
        assert(actual == expected, details)

static func fail(message: String) -> void:
    push_error("TEST FAILED: %s" % message)
    assert(false, message)
