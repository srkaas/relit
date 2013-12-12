require 'wordnet'

l = WordNet::Lexicon.new

# Convert a word string to a randomly chosen synonym set compatible with the word.
def string_to_synset(s, lexicon)
  possible_synsets = lexicon.lookup_synsets(s.to_sym)
  if possible_synsets.empty?
    return nil
  else
    return possible_synsets.sample
  end
end

# Convert a synonym set to a string containing a randomly chosen word compatible with it.
def synset_to_string(synset)
  unless synset == nil
    possible_strings = synset.words
    return possible_strings.sample
  else
    return '...'
  end
end

# Return a random hypernym of a synonym set.
def random_parent(synset)
  unless synset == nil
    possible_parents = synset.hypernyms
    unless possible_parents.empty?
      return possible_parents.sample
    else
      return nil
    end
  else
    return nil
  end
end

# Convert a text into a different text.
def improve_text(text, lexicon)
  return synset_to_string(random_parent(string_to_synset(text, lexicon)))
end

# Test text conversion with a particular text.
def test_me_with(text, lexicon)
  puts "#{text} becomes #{improve_text(text, lexicon)}"
end

# Test text conversion with a list of words.
def test_me(lexicon)
  test_words = ['shoe', 'thisisnotaword', 'thing', 'entity', 'crow', 'dog', 'tulip', 'person', 'apple', 'ruby']
  test_words.each do |word|
    test_me_with(word, lexicon)
  end
end

test_me(l)
