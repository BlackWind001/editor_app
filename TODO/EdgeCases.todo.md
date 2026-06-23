# Edge cases to handle:

1. Currently I am using `\n` as the default value for an editor whose path has not been mentioned. If I use an empty string, then no lines show up and user cannot input. Ideally, user should be able to input.
2. There are going to be cases when there is no workspace for the user to work with . What happens to saves or other file operations in the context of a workspace not being present?