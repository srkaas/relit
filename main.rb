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
  if synset.nil?
    return '...'
  else
    possible_strings = synset.words
    return possible_strings.sample
  end
end

# Return a random synonym set that is a hypernym of the current synonym set, i.e., something more general.
def random_parent(synset)
  if synset.nil?
    return nil
  else
    possible_parents = synset.hypernyms
    if possible_parents.empty?
      return nil
    else
      return possible_parents.sample
    end
  end
end

# Return a random synonym set that is a hyponym of the current synonym set, i.e., something more specific.
def random_child(synset)
  if synset.nil?
    return nil
  else
    possible_children = synset.hyponyms
    if possible_children.empty?
      return nil
    else
      return possible_children.sample
    end
  end
end

# Return a random synonym set that is a hyponym of a hypernym of the current synonym set, i.e. something of the same kind.
def random_sibling(synset)
  if synset.nil?
    return nil
  else
    possible_siblings = []
    synset.hypernyms.each do |hypernym|
      hypernym.hyponyms.each do |hyponym|
        possible_siblings << hyponym
      end
    end
    if possible_siblings.empty?
      return nil
    else
      return possible_siblings.sample
    end
  end
end

# Convert a word into a different word.
def improve_word(word, lexicon)
  improved = synset_to_string(random_sibling(string_to_synset(word, lexicon)))
  # If the process failed to find a modified word, just use the original word.
  if improved == '...'
    return word
  else
    return improved
  end
end

# Convert a text into a different text by converting each word of the text into a different word.
def improve_text(text, lexicon)
  return text.gsub(/\w+/) { |word| improve_word(word, lexicon) }
end

# Test text conversion with a particular text.
def test_me_with(text, lexicon)
  puts text
  puts 'becomes'
  puts improve_text(text, lexicon)
end

# Test text conversion with a list of words.
def test_me(lexicon)
  test_text = "This is our test sentence, which we are using to test the program: that way, we can see whether or not the program works. "
  test_me_with(test_text, lexicon)
end

test_me(l)
