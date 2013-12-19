require 'wordnet'
require 'pickup'

IMPROVE_WORD_RETRIES = 10
STANDARD_IMPROVEMENTS_HASH = {'child' => 10, 'parent' => 10, 'sibling' => 10, 'synonym' => 10, 'define' => 3, 'nothing' => 40}
CONTINUE_IMPROVING_PROBABILITY = 0.8
MAX_CONTINUE_IMPROVING = 2

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

# Return a random synonym set that is a hyponym of a hypernym of the current synonym set, i.e., something of the same kind.
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
def improve_word(word, lexicon, times_tried=0, improvement='child')
  if improvement == 'sibling'
    improved = synset_to_string(random_sibling(string_to_synset(word, lexicon)))
  elsif improvement == 'child'
    improved = synset_to_string(random_child(string_to_synset(word, lexicon)))
  elsif improvement == 'parent'
    improved = synset_to_string(random_parent(string_to_synset(word, lexicon)))
  elsif improvement == 'define'
    corresponding_synset = string_to_synset(word, lexicon)
    if corresponding_synset.nil?
      improved = '...'
    else
      improved = corresponding_synset.definition
    end
  elsif improvement == 'nothing'
    improved = word
  elsif improvement == 'synonym'
    improved = synset_to_string(string_to_synset(word, lexicon))
  end
  # If the process failed to find a modified word, retry a number of times and then just use the original word.
  if improved == '...'
    if times_tried < IMPROVE_WORD_RETRIES
      return improve_word(word, lexicon, times_tried + 1)
    else
      return word
    end
  else
    return improved
  end
end

def probabilistic_improve_word(word, lexicon, improvements_hash=STANDARD_IMPROVEMENTS_HASH)
  pickup = Pickup.new(improvements_hash)
  picked_improvement = pickup.pick
  return improve_word(word, lexicon, 0, picked_improvement)
end

def probabilistic_improve_all_words(text, lexicon, improvements_hash=STANDARD_IMPROVEMENTS_HASH)
  return text.gsub(/\w+/) { |word| probabilistic_improve_word(word, lexicon, improvements_hash) }
end

# Convert a text into a different text by converting each word of the text into a different word.
def improve_text(text, lexicon)
  text = probabilistic_improve_all_words(text, lexicon)
  return text
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

