// Rot13 transformation function
function rot13(text) {
    return text.replace(/[a-zA-Z]/g, function (char) {
        return String.fromCharCode(
            (char <= "Z" ? 90 : 122) >= (char = char.charCodeAt(0) + 13)
                ? char
                : char - 26
        );
    });
}

module.exports = rot13;
