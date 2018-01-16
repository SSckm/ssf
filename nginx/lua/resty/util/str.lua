-- Zhenxing Liu

local _M = {}

local function str_split(_source_str, _s_char, _s_char_length)
  if nil == _source_str or nil == _s_char then
    return nil
  end
  local _index = 1
  local _n_index = 1
  local array = {}
  while true do
    local _n_find_index = string.find(_source_str, _s_char, _index)
    if not _n_find_index then
      array[_n_index] = string.sub(_source_str, _index, string.len(_source_str))
      break
    end
    array[_n_index] = string.sub(_source_str, _index, _n_find_index - 1)
    _index = _n_find_index + ( _s_char_length or string.len(_s_char))
    _n_index = _n_index + 1
  end
  return array
end

function _M.split(_source_str, _s_char, _s_char_length)
  return str_split(_source_str, _s_char, _s_char_length)
end

function _M.get_time()
    return os.date("%Y%m%d")
end

function _M.get_time_mi()
    return os.date("%Y%m%d%H%M")
end

function _M.trim(s)
  return s:match"^%s*(.*)":match"(.-)%s*$"
end

return _M
