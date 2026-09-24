"""Regression tests for the public documentation gate."""

import importlib.util
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "check-doc-comments.py"
spec = importlib.util.spec_from_file_location("check_doc_comments", SCRIPT)
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)


class DocCommentCheckTests(unittest.TestCase):
    def check_source(self, source):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Fixture.swift"
            path.write_text(source, encoding="utf-8")
            return checker.check_file(path)

    def test_documented_public_symbols_pass(self):
        failures = self.check_source(
            """/// A public status.
public enum Status {
    /// Ready for use.
    case ready
}
/// A public capability.
public protocol Actionable {
    /// Runs an action.
    func run()
}
"""
        )
        self.assertEqual(failures, [])

    def test_undocumented_enum_case_and_protocol_requirement_fail(self):
        failures = self.check_source(
            """/// A public status.
public enum Status {
    case ready
}
/// A public capability.
public protocol Actionable {
    func run()
}
"""
        )
        self.assertEqual(len(failures), 2)
        self.assertIn("case ready", failures[0])
        self.assertIn("func run()", failures[1])

    def test_public_extension_member_needs_doc_but_private_member_does_not(self):
        failures = self.check_source(
            """public extension String {
    func exposed() {}
    private func hidden() {}
}
"""
        )
        self.assertEqual(len(failures), 1)
        self.assertIn("func exposed()", failures[0])


if __name__ == "__main__":
    unittest.main()
