from auth import check_credentials

if __name__ == '__main__':
    print('Testing credentials...')
    user = check_credentials('mario.rossi@mail.com', 'pass123')
    print('Result:', user)
