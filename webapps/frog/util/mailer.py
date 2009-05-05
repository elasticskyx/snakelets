import time
from smtplib import SMTP, SMTPException
from email.MIMEText import MIMEText
import email.Utils
import socket


# override the default email charsets to avoid ugly base-64 or q.p. encodings.
import email.Charset
email.Charset.add_charset( 'iso-8859-15', email.Charset.SHORTEST, None, None )
email.Charset.add_charset( 'utf-8', email.Charset.SHORTEST, None, None )

EMAIL_ENCODING = 'iso-8859-15'


class MailServer:
    def __init__(self, smtpserver, user=None, password=None, senderAddress=None, replytoAddress=None):
        self.smtpserver=smtpserver
        self.user=user
        self.password=password
        self.sender=senderAddress
        self.replyto=replytoAddress
        try:
            # validate the smtp connection
            smtp=SMTP(self.smtpserver)
            if self.user:
                smtp.login(self.user, self.password)
            smtp.quit()
        except socket.error,x:
            raise SMTPException("could not connect to smtp server")

    def mail(self, toaddr, subject, body, encoding=EMAIL_ENCODING, fromaddr=None, replyto=None):
        if type(body) is unicode:
            body = body.encode(encoding, 'replace')
        mimetxt = MIMEText(body, _charset = encoding)
        fromaddr=fromaddr or self.sender
        mimetxt['From']=fromaddr
        mimetxt['To']=toaddr
        mimetxt['Subject']=subject
        mimetxt['Date']=email.Utils.formatdate(localtime=True)
        replyto = replyto or self.replyto
        if replyto:
            mimetxt['Reply-To'] = replyto
        smtp=SMTP(self.smtpserver)
        if self.user:
            smtp.login(self.user, self.password)
        smtp.sendmail(fromaddr, toaddr, mimetxt.as_string())
        smtp.quit()

