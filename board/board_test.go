package board

import (
	"log"
	"os"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

var f *Forum

func TestMain(m *testing.M) {
	var err error
	f, err = GetForum(DefaultBoardURL, false)
	if err != nil {
		log.Fatal(err)
	}
	code:= m.Run()
	os.Exit(code)
}

// func TestForum(t *testing.T) {

// 	assert.Equal(t, "1", f.Boards[0].ID)
// 	assert.Equal(t, "2", f.Boards[1].ID)
// 	assert.Equal(t, "4", f.Boards[2].ID)
// 	assert.Equal(t, "6", f.Boards[3].ID)
// 	assert.Equal(t, "26", f.Boards[4].ID)
// 	// Boards after this might change due to events like E3 or WM
// }

func TestBoard(t *testing.T) {

	forum := f.GetBoard("6")
	threads := forum.Threads

	// Expect some threads to be present
	assert.Greater(t, len(threads), 0)
	assert.Equal(t, "6", forum.ID)
	assert.Equal(t, "Smalltalk", forum.Title)

}

func TestThread(t *testing.T) {
	thread := f.GetThread("1460", "6")
	if len(thread.Messages) == 0 {
		t.Errorf("No messages returned")
	}
	t.Log(thread.Messages)
	assert.Greater(t, len(thread.Messages), 0)
}

func TestMessage(t *testing.T) {
	message, err := f.GetMessage("pxmboard.php?mode=message&brdid=6&msgid=87139")
	assert.Nil(t, err)
	t.Log("Message: ", message.Content)
	t.Log("Link: ", message.Link)
	expected := "ist jemand von hier"
	if !strings.Contains(message.Content, expected) {
		t.Errorf("Message does not match, was '%s', expected '%s'", message.Content, expected)
	}
	expectedAuthor := "ossi_osram"
	if expectedAuthor != message.Author.Name {
		t.Errorf("Author does not match, was '%s', expected '%s'", message.Author.Name, expectedAuthor)
	}
}

func TestSearch(t *testing.T) {

	query := "Nvidia RTX"
	authorName := "wiede"
	messages, err := f.searchMessages(query, authorName, "-1", false, true)
	assert.Nil(t, err)

	// Search may or may not return results depending on forum state
	if len(messages) > 0 {
		assert.Equal(t, messages[0].Author.Name, authorName)
	}
}

func TestSearchEmptyResult(t *testing.T) {

	query := "Query for user that hopefully will never exist"
	authorName := "hopefully this user will never exist"
	messages, err := f.searchMessages(query, authorName, "-1", false, true)
	assert.Nil(t, err)

	assert.Equal(t, len(messages), 0)

}
